module Dao
  module Gateway
    module ActiveRecord
      class BaseTransformer < Dao::Gateway::ScopeTransformer
        def one(relation)
          super(Array(relation))
        end

        private

        def transform(relation)
          super(relation) do |record|
            collect_attributes(record, associations)
          end
        end

        def collect_attributes(record, associations)
          associations = associations.first if associations.count == 1
          ::HashWithIndifferentAccess.new(record.try(:serializable_hash, force_except: [], include: associations))
        end
      end
    end
  end
end
