require 'spec_helper'

describe DataMapper::Adapters::Dynamodb::Adapter do
  
  before(:all) do
    @adapter = DataMapper.setup(:default,
        { :adapter  => :dynamodb,
          :aws_access_key_id => TEST_ACCESS_KEY_ID,
          :aws_secret_access_key => TEST_SECRET_ACCESS_KEY,
          :hash_key_type => HEFFALUMP_ID_TYPE
        }
    )
  end
  #it_should_behave_like 'An Adapter'
  
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
    before :each do
      @heffa = heffalump_model.create(:color => 'indigo')
    end

    it 'should not raise any errors' do
      @heffa.color = 'violet'
      @heffa.save
    end

    it 'should not alter the identity field' do
      id = @heffa.id
      @heffa.color = 'violet'
      @heffa.save
      @heffa.id.should == id
    end

    it 'should update altered fields' do
      @heffa.color = 'violet'
      @heffa.save
      heffalump_model.get(*@heffa.key).color.should == 'violet'
    end

    it 'should not alter other fields' do
      color = @heffa.color
      @heffa.num_spots = 3
      @heffa.save
      heffalump_model.get(*@heffa.key).color.should == color
    end
  end
  
end