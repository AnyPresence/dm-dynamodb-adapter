require 'rubygems'
require 'pathname'

# Support running specs with 'rake spec' and 'spec'
$LOAD_PATH.unshift('lib') unless $LOAD_PATH.include?('lib')

require 'dm-dynamodb-adapter'
require 'dm-core/spec/shared/adapter_spec'

DataMapper::Logger.new(STDOUT, :debug)

ROOT = Pathname(__FILE__).dirname.parent

Pathname.glob((ROOT + 'spec/fixtures/**/*.rb').to_s).each { |file| require file }
Pathname.glob((ROOT + 'spec/**/shared/**/*.rb').to_s).each { |file| require file }

TEST_ACCESS_KEY_ID = ENV['AWS_DYNAMODB_TEST_ACCESS_KEY_ID']
TEST_SECRET_ACCESS_KEY = ENV['AWS_DYNAMODB_TEST_SECRET_ACCESS_KEY']

HEFFALUMP_ID_MAPPING = :id
HEFFALUMP_ID_TYPE = :number

raise "AWS credentials not found. Please set both environment variables to run tests: AWS_DYNAMODB_TEST_ACCESS_KEY_ID and AWS_DYNAMODB_TEST_SECRET_ACCESS_KEY" if TEST_ACCESS_KEY_ID.nil? || TEST_SECRET_ACCESS_KEY.nil?

ENV['ADAPTER'] = 'Dynamodb'
ENV['ADAPTER_SUPPORTS'] = 'all'

def heffalump_model
  Huffalump
end

def create_test_table(dynamo_db, table_name)
  if dynamo_db.tables[table_name].exists?
    table = dynamo_db.tables[table_name]
    table.hash_key = [HEFFALUMP_ID_MAPPING, HEFFALUMP_ID_TYPE]
    print "Clearing existing records"
    table.items.select do |data|
      print '.'
      data.item.delete
    end
    puts "Done."
  else
    print "Creating table"
    table = dynamo_db.tables.create(table_name, 1, 1, :hash_key => { HEFFALUMP_ID_MAPPING => HEFFALUMP_ID_TYPE })
    until table.status == :active
      print '.'
      sleep 1 
    end
  end
end

dynamo_db = AWS::DynamoDB.new(:access_key_id => TEST_ACCESS_KEY_ID,:secret_access_key => TEST_SECRET_ACCESS_KEY)    
create_test_table(dynamo_db,'heffalumps')
DataMapper.finalize