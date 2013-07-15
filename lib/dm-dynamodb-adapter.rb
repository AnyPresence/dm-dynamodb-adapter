require 'dm-core'
require 'aws-sdk'

require 'dm-dynamodb-adapter/adapter'

::DataMapper::Adapters::DynamodbAdapter = DataMapper::Adapters::Dynamodb::Adapter
::DataMapper::Adapters.const_added(:DynamodbAdapter)