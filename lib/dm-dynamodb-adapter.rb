require 'dm-core'
require 'aws-sdk'

require 'dm-dynamodb-adapter/adapter'

::DataMapper::Adapters::DynamoDBAdapter = DataMapper::Adapters::DynamoDB::Adapter
::DataMapper::Adapters.const_added(:DynamoDBAdapter)