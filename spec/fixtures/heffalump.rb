class ::Heffalump
  include ::DataMapper::Resource
  
  property :id, ::DataMapper::Property::Serial, field: "_id"
  property :color, ::DataMapper::Property::String
  property :num_spots, ::DataMapper::Property::Integer
  property :latitude, ::DataMapper::Property::Float
  property :striped, ::DataMapper::Property::Boolean
  property :created, ::DataMapper::Property::DateTime
  property :at, ::DataMapper::Property::Time, field: "at_time"
  def self.name; 'Heffalump'; end
end