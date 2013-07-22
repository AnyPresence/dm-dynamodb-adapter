module DataMapper
  module Adapters
    module Dynamodb
      class Adapter < DataMapper::Adapters::AbstractAdapter
        include QueryDelegate
        
        HASH_KEY_TYPES = [:string, :number, :binary].freeze
        
        def initialize(name, options)
          super
          access_key_id = @options.fetch(:aws_access_key_id)
          secret_access_key = @options.fetch(:aws_secret_access_key)
          @db = AWS::DynamoDB.new(:access_key_id => access_key_id,:secret_access_key => secret_access_key)
          DataMapper.logger.debug("Connected to #{@db}")
          @hash_key_type = @options.fetch(:hash_key_type, HASH_KEY_TYPES.first)
          raise "Key type must be one of #{HASH_KEY_TYPES.join(', ')}" unless HASH_KEY_TYPES.include?(@hash_key_type)
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
          model = query.model
          serial = model.serial.field
          table = load_table(model.storage_name(query.repository), serial)
                  
          begin
            execute_query(query, table)
          rescue => e
            DataMapper.logger.error("Query failed #{e}")
          end
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
          created = 0
          name = self.name
          resources.each do |resource|
            model = resource.model
            serial = model.serial(name)
            id = generate_id(@hash_key_type)
            
            attributes = resource.attributes(:field)
            attributes[serial.field] = id
            attributes = to_dynamodb_hash(resource, attributes)
            
            begin
              table = load_table(model.storage_name, serial.field)
              stored_item = table.items.create(attributes)
              initialize_serial(resource, id)
              DataMapper.logger.debug("Saved resource is now #{resource.inspect}")
              created += 1
            rescue => e
              DataMapper.logger.error("Failure #{e.inspect}")
            end
          end
          DataMapper.logger.debug("Created #{created} records.")
          created
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
          updated = 0

          collection.each do |resource|
            model = resource.model
            serial = model.serial.field
            begin
              table = load_table(model.storage_name, serial)
              item = table.items[resource.attribute_get(serial)]
            
              attributes.each do |property, object|
                DataMapper.logger.debug("Setting #{property.field} = #{object}")
                item.attributes.update do |u|
                  u.set(property.field => object)
                end
              end
              updated += 1
            rescue => e
              DataMapper.logger.error("Failure while updating #{e.inspect}")
            end
          end
          
          updated
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
          deleted = 0
          
          collection.each do |resource|
            model = resource.model
            serial = model.serial.field
            
            begin
              table = load_table(model.storage_name, serial)
              item = table.items[resource.attribute_get(serial)]
              item.delete
              deleted += 1
            rescue => e
              DataMapper.logger.error("Failure while deleting #{e.inspect}")
            end
          end
          
          deleted
        end
        
        private
        
        def generate_id(type)
          uuid = SecureRandom.uuid
          case type
          when :string
            uuid
          when :number
            #@next_id += 1 #
            uuid.gsub('-','').to_i 
          when :binary
            uuid.gsub('-','').hex
          else
            raise "Unsupported id type #{type}"
          end
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
            property = field_to_property[field]

            if property.nil?
              property = field_to_property[field.to_sym]
            end

            if property.instance_of? DataMapper::Property::Object
              raise "Array properties are not yet supported! Or are they?"
            else
              next unless property
              record[property.field.to_s] = property.typecast(value)
            end
          end
          record
        end
        
        
        def make_field_to_property_hash(repository_name, model)
          Hash[ model.properties(repository_name).map { |p| [ p.field, p ] } ]
        end
        
        def load_table(table_name, key)
          table = @db.tables[table_name]
          table.hash_key = [key, @hash_key_type]
          table
        end
      end
    end
  end
end