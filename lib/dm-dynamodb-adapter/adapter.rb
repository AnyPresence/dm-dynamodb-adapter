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
      end
    end
  end
end