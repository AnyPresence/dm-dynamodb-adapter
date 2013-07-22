module DataMapper
  module Adapters
    module Dynamodb
      module QueryDelegate
        
        def execute_query(query, table)
          records = []
          
          fields = query.fields.map{ |property| property.field }
          conditions = query.conditions
          order = query.order
          limit = query.limit
          offset = query.offset
          
          DataMapper.logger.debug("Query fields are #{fields.inspect}")
          @aws_query = table.items
          build_conditions(conditions) if conditions
          @aws_query.select(*fields).each do |item_data|
            DataMapper.logger.debug("Item data is #{item_data.attributes.inspect}")
            records << parse_record(query.repository, query.model, item_data.attributes)
          end
          records
        end
        
        private

# @conditions=#<DataMapper::Query::Conditions::AndOperation:0x007f9feac3d890 
    @operands=#<Set: {#<DataMapper::Query::Conditions::EqualToComparison @subject=#<DataMapper::Property::Serial @model=Huffalump @name=:id> @dumped_value=63 @loaded_value=63>}>
       
       #> @order=nil @limit=1 @offset=0 @reload=false @unique=false> and its model is Huffalump
        
        def build_conditions(conditions)
          conditions.each do |condition|
            if condition.instance_of? DataMapper::Query::Conditions::EqualToComparison
              @aws_query = @aws_query.where(condition.subject.field.to_sym).equals(condition.loaded_value)
            else
              raise "build_conditions #{condition.class} is not yet supported!"
            end
          end
        end
        
      end
    end
  end
end