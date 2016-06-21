describe Dao::Gateway::ActiveRecord::Base do
  let(:entity) { Struct.new(:attribute, :initialized_with) }
  let(:transformer) { Dao::Gateway::ActiveRecord::BaseTransformer.new(entity) }
  let(:source) do
    Class.new(ActiveRecord::Base) do |s|
      s.has_one :other_source
    end
  end
  let(:gateway) { described_class.new(source, transformer) }

  subject { gateway }

  its(:source) { is_expected.to eq source }
  its(:transformer) { is_expected.to eq transformer }
  its(:black_list_attributes) { is_expected.to eq [:other_source] }
end
