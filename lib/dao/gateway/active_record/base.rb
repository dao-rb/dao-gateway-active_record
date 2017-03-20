module Dao
  module Gateway
    module ActiveRecord
      class Base < Dao::Gateway::Base
        include ActiveSupport::Rescuable

        def initialize(source, transformer)
          super
          @black_list_attributes += source_relations
        end

        def save!(domain, attributes)
          record = export(domain, record(domain.id))
          record.assign_attributes(attributes)
          record.save!
          domain.attributes = import(record, domain.initialized_with).attributes
          domain
        rescue ::ActiveRecord::RecordInvalid
          raise Dao::Gateway::InvalidRecord.new(record.errors.to_hash)
        rescue ::ActiveRecord::RecordNotFound => e
          raise Dao::Gateway::RecordNotFound, e.message
        rescue Exception => e
          rescue_with_handler(e) || raise
        end

        def delete(domain_id)
          record(domain_id).destroy if domain_id.present?
        end

        def chain(scope, method_name, args, &block)
          scope.public_send(method_name, *args, &block)
        rescue ::ActiveRecord::RecordNotFound => e
          raise Dao::Gateway::RecordNotFound, e.message
        end

        def add_relations(scope, relations, options)
          case options[:strategy]
            when :preload
              scope.preload(*relations)
            when :includes
              scope.includes(*relations)
            else
              scope.eager_load(*relations)
          end
        end

        def with_transaction(&block)
          source.transaction(&block)
        end

        def with_lock(id, *args, &block)
          source.transaction do
            source.lock(*args).find(id)
            block.call
          end

        rescue ::ActiveRecord::StatementInvalid => e
          raise Dao::Gateway::StatementInvalid, e.message
        end

        protected

        def export(base, record = nil)
          return unless base
          record ||= source.new
          attributes = base.attributes.except(*@black_list_attributes)

          record.assign_attributes(attributes)
          record
        end

        def record(domain_id)
          source.find_by_id(domain_id) if domain_id.present?
        end

        def source_relations
          @_relations ||= @source.reflections.keys.map(&:to_sym)
        end

        def collection_scope?(relation)
          if relation.is_a?(::ActiveRecord::Relation)
            true
          elsif relation.is_a?(Array)
            source_scope?(relation.first)
          else
            false
          end
        end
      end
    end
  end
end
