require 'dm-core'
require 'dm-types'

require 'aws-sdk'
require 'securerandom'
require 'dm-dynamodb-adapter/query_delegate'
require 'dm-dynamodb-adapter/adapter'

::DataMapper::Adapters::DynamodbAdapter = DataMapper::Adapters::Dynamodb::Adapter
::DataMapper::Adapters.const_added(:DynamodbAdapter)