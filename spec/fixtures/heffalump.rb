class ::Heffalump
  include ::DataMapper::Resource
  
  property :id, ::DataMapper::Property::Serial, key: true, field: "_id"
  property :color, ::DataMapper::Property::String
  property :num_spots, ::DataMapper::Property::Integer
  property :striped, ::DataMapper::Property::Boolean

end