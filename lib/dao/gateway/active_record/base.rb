module Dao
  module Gateway
    module ActiveRecord
      class Base < Dao::Gateway::Base
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
        rescue CarrierWave::FormNotMultipart => e
          raise Dao::Gateway::InvalidRecord.new(base: e.message)
        rescue ::ActiveRecord::RecordNotFound => e
          raise Dao::Gateway::RecordNotFound, e.message
        end

        def delete(domain_id)
          record(domain_id).destroy if domain_id.present?
        end

        def chain(scope, method_name, args, &block)
          scope.public_send(method_name, *args, &block)
        rescue ::ActiveRecord::RecordNotFound => e
          raise Dao::Gateway::RecordNotFound, e.message
        end

        def add_relations(scope, relations)
          scope.eager_load(*relations)
        end

        def with_transaction(&block)
          source.transaction(&block)
        end

        protected

        def export(base, record = nil)
          return unless base
          record ||= source.new
          attributes = base.attributes.except(*@black_list_attributes)

          record.assign_attributes(attributes)
          record
        end

        def import(relation, associations)
          @transformer.associations = associations
          unless relation.nil?
            if collection_scope?(relation)
              @transformer.many(relation)
            elsif source_scope?(relation)
              @transformer.one(relation)
            else
              @transformer.other(relation)
            end
          end
        end

        def record(domain_id)
          source.find_by_id(domain_id) if domain_id.present?
        end

        def source_relations
          @_relations ||= @source.reflections.keys.map(&:to_sym)
        end

        private

        def collection_scope?(relation)
          if relation.is_a?(::ActiveRecord::Relation)
            true
          elsif relation.is_a?(Array)
            source_scope?(relation.first)
          else
            false
          end
        end

        def source_scope?(relation)
          relation.is_a?(source)
        end
      end
    end
  end
end
