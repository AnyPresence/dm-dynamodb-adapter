class Huffalump
  include DataMapper::Resource
  
  property :id, DataMapper::Property::Serial
  property :color, DataMapper::Property::String
  property :num_spots, DataMapper::Property::Integer
  property :striped, DataMapper::Property::Boolean
  
  # This is needed for DataMapper.finalize
  def self.name; 'Heffalump'; end
end