module Dao
  module Gateway
    module ActiveRecord
      class RecordProcessor < Gateway::Processor
        def process(record, associations, *)
          associations = associations.first if associations.count == 1

          ::HashWithIndifferentAccess.new(record.try(:serializable_hash, force_except: [], include: associations))
        end
      end
    end
  end
end
