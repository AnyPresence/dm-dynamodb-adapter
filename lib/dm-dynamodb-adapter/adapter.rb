module DataMapper
  module Adapters
    module Dynamodb
      class Adapter < DataMapper::Adapters::AbstractAdapter
        
        def initialize(name, options)
          super
          access_key_id = @options.fetch(:aws_access_key_id)
          secret_access_key = @options.fetch(:aws_secret_access_key)
          @db = AWS::DynamoDB.new(:access_key_id => access_key_id,:secret_access_key => secret_access_key)
          DataMapper.logger.debug("Connected to #{@db}")
        end
        
        # Reads one or many resources from a datastore
        #
        # @example
        #   adapter.read(query)  # => [ { 'name' => 'Dan Kubb' } ]
        #
        # Adapters provide specific implementation of this method
        #
        # @param [Query] query
        #   the query to match resources in the datastore
        #
        # @return [Enumerable<Hash>]
        #   an array of hashes to become resources
        #
        # @api semipublic
        def read(query)
          DataMapper.logger.debug("Read #{query.inspect} and its model is #{query.model.inspect}")
#<DataMapper::Query @repository=:default @model=Heffalump @fields=[#<DataMapper::Property::Serial @model=Heffalump @name=:id>, #<DataMapper::Property::String @model=Heffalump @name=:color>, #<DataMapper::Property::Integer @model=Heffalump @name=:num_spots>, #<DataMapper::Property::Boolean @model=Heffalump @name=:striped>] @links=[] @conditions=nil @order=[#<DataMapper::Query::Direction @target=#<DataMapper::Property::Serial @model=Heffalump @name=:id> @operator=:asc>] @limit=nil @offset=0 @reload=false @unique=false>
          model = query.model
          repository = query.repository
          key = key_mapping(model)
          table = @db.tables[model.storage_name(repository)]
          table.hash_key = [key, :string]
          raise "Table #{table.name} not found." unless table.schema_loaded?
                  
          fields = query.fields.map{ |field| field.name.to_s }
          conditions = query.conditions
          order = query.order
          limit = query.limit
          offset = query.offset
          records = []
          DataMapper.logger.debug("Query fields are #{fields.inspect}")
          table.items.select(*fields).each do |item_data|
            DataMapper.logger.debug("Item data is #{item_data.attributes.inspect}")
            records << parse_record(repository, model, item_data.attributes)
          end
          DataMapper.logger.debug("Query pulled #{records.inspect}")
          records
        end
        
        # Persists one or many new resources
        #
        # @example
        #   adapter.create(collection)  # => 1
        #
        # Adapters provide specific implementation of this method
        #
        # @param [Enumerable<Resource>] resources
        #   The list of resources (model instances) to create
        #
        # @return [Integer]
        #   The number of records that were actually saved into the data-store
        #
        # @api semipublic  
        def create(resources)
          resources.each do |resource|
            model = resource.model
            serial = model.serial
            key = key_mapping(model)
            id = generate_id(serial)

            table = @db.tables[model.storage_name]
            table.hash_key = [key, :string]
            raise "Table #{table.name} not found." unless table.schema_loaded?
            
            attributes = resource.attributes(:field)
            DataMapper.logger.debug("Serial is #{serial.inspect}")
            attributes[key] = id
            attributes = to_dynamodb_hash(resource, attributes)
            DataMapper.logger.debug("About to create #{model} using #{attributes} in #{table.name}")
            table.items.create(attributes)
            serial.set!(resource, id)
          end.size
        end
        
        # Updates one or many existing resources
        #
        # @example
        #   adapter.update(attributes, collection)  # => 1
        #
        # Adapters provide specific implementation of this method
        #
        # @param [Hash(Property => Object)] attributes
        #   hash of attribute values to set, keyed by Property
        # @param [Collection] collection
        #   collection of records to be updated
        #
        # @return [Integer]
        #   the number of records updated
        #
        # @api semipublic
        def update(attributes, collection)
          DataMapper.logger.debug("Update called with:\nAttributes #{attributes.inspect} \nCollection: #{collection.inspect}")
          raise "Implement me!"
        end
        
        # Deletes one or many existing resources
        #
        # @example
        #   adapter.delete(collection)  # => 1
        #
        # Adapters provide specific implementation of this method
        #
        # @param [Collection] collection
        #   collection of records to be deleted
        #
        # @return [Integer]
        #   the number of records deleted
        #
        # @api semipublic
        def delete(collection)
          DataMapper.logger.debug("Delete called with: #{collection.inspect}")
          raise "Implement me!"
        end
        
        private
        
        def generate_id(serial)
          SecureRandom.uuid()
        end
        
        def to_dynamodb_hash(resource, attributes)
          DataMapper.logger.debug("to_dynamodb_hash called with model #{resource.model} and properties #{attributes}")
          field_to_property = make_field_to_property_hash(resource.repository, resource.model)
          aws_attributes = {}
          attributes.each do |property, value|
            name = field_to_property[property].field
            aws_attributes[name] = value
          end
          aws_attributes
        end
        
        def parse_record(repository, model,hash)
          field_to_property = make_field_to_property_hash(repository, model)
          DataMapper.logger.debug("parse_record is converting #{hash.inspect} for model #{model}")
          record = record_from_hash(hash, field_to_property)
          DataMapper.logger.debug("Record made from hash is #{record}")
          record
        end
                
        def record_from_hash(hash, field_to_property)
          record = {}
          hash.each do |field, value|
            DataMapper.logger.debug("#{field} = #{value}")
            name = field.to_s
            property = field_to_property[name]

            if property.nil?
              property = field_to_property[name.to_sym]
            end

            if property.instance_of? DataMapper::Property::Object
              raise "Array properties are not yet supported! Or are they?"
            else
              next unless property
              record[name] = property.typecast(value)
            end
          end
          record
        end
        
        
        def make_field_to_property_hash(repository_name, model)
          Hash[ model.properties(repository_name).map { |p| [ p.field, p ] } ]
        end
   
        def key_mapping(model)
          model.serial.field.to_s
        end
      end
    end
  end
end