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
          table.items.select(*fields).each do |item_data|
            DataMapper.logger.debug("Item data is #{item_data.attributes.inspect}")
            records << parse_record(query.repository, query.model, item_data.attributes)
          end
          records
        end
        
      end
    end
  end
end