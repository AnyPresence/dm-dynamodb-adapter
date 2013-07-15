require 'spec_helper'

describe DataMapper::Adapters::DynamoDB::Adapter do
  before(:all) do
    @adapter = DataMapper.setup(:default,
        { :adapter  => :dynamodb,
          :aws_access_key_id => TEST_ACCESS_KEY_ID,
          :aws_secret_access_key => TEST_SECRET_ACCESS_KEY
        }
    )
  end
  
end