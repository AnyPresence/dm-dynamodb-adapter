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
          raise "Implement me!"
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
            id = generate_id(serial)
            
            table = @db.tables[model.storage_name]
            table.hash_key = [serial.field, :string]
            raise "Table #{model.storage_name} not found." unless table.schema_loaded?
            
            fields = resource.attributes(:field)
            fields[serial.field] = id
            DataMapper.logger.debug("About to create #{model} using #{fields} in #{table.name}")
            table.items.create(fields)
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
        
        def generate_id(key)
          SecureRandom.uuid()
        end
      end
    end
  end
end