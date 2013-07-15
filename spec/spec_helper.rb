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

raise "AWS credentials not found. Please set both environment variables to run tests: AWS_DYNAMODB_TEST_ACCESS_KEY_ID and AWS_DYNAMODB_TEST_SECRET_ACCESS_KEY" if TEST_ACCESS_KEY_ID.nil? || TEST_SECRET_ACCESS_KEY.nil?

ENV['ADAPTER'] = 'DynamoDB'
ENV['ADAPTER_SUPPORTS'] = 'all'

DataMapper.finalize