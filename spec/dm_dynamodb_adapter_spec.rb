require 'spec_helper'

describe DataMapper::Adapters::Dynamodb::Adapter do

  before(:all) do
    @adapter = DataMapper.setup(:default,
        { :adapter  => :dynamodb,
          :aws_access_key_id => TEST_ACCESS_KEY_ID,
          :aws_secret_access_key => TEST_SECRET_ACCESS_KEY
        }
    )
    
    dynamo_db = AWS::DynamoDB.new(:access_key_id => TEST_ACCESS_KEY_ID,:secret_access_key => TEST_SECRET_ACCESS_KEY)    
    create_test_table(dynamo_db,'heffalumps')
  end
  
  describe '#create' do
    it 'should not raise any errors' do
      lambda {
        heffalump_model.create(:color => 'peach')
      }.should_not raise_error
    end

    it 'should set the identity field for the resource' do
      heffalump = heffalump_model.new(:color => 'peach')
      heffalump.id.should be_nil
      heffalump.save
      heffalump.id.should_not be_nil
    end
  end
  
  describe '#read' do
    before :all do
      @heffalump = heffalump_model.create(:color => 'brownish hue')
      @query = heffalump_model.all.query
    end

    it 'should not raise any errors' do
      lambda {
        heffalump_model.all()
      }.should_not raise_error
    end

    it 'should return stuff' do
      heffalump_model.all.should be_include(@heffalump)
    end
  end
  
  describe '#update' do
    before :all do
      @heffalump = heffalump_model.create(:color => 'indigo')
    end

    it 'should not raise any errors' do
      lambda {
        @heffalump.color = 'violet'
        @heffalump.save
      }.should_not raise_error
    end

    it 'should not alter the identity field' do
      id = @heffalump.id
      @heffalump.color = 'violet'
      @heffalump.save
      @heffalump.id.should == id
    end

    it 'should update altered fields' do
      @heffalump.color = 'violet'
      @heffalump.save
      heffalump_model.get(*@heffalump.key).color.should == 'violet'
    end

    it 'should not alter other fields' do
      color = @heffalump.color
      @heffalump.num_spots = 3
      @heffalump.save
      heffalump_model.get(*@heffalump.key).color.should == color
    end
  end
  
end