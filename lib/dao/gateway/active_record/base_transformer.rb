module Dao
  module Gateway
    module ActiveRecord
      class BaseTransformer < Dao::Gateway::ScopeTransformer
        def one(relation)
          super(Array(relation))
        end

        private

        def add_processors
          @processors.unshift RecordProcessor.new
        end
      end
    end
  end
end
