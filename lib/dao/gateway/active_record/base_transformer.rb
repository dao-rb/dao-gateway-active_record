module Dao
  module Gateway
    module ActiveRecord
      class BaseTransformer < Dao::Gateway::ScopeTransformer
        def add_processors
          pipe.preprocess(RecordProcessor.new)
        end
      end
    end
  end
end
