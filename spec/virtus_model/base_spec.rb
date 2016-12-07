describe VirtusModel::Base do
  class SimpleModel < VirtusModel::Base
    attribute :name, String
    validates :name, presence: true
  end

  let(:simple_model) { SimpleModel.new(simple_model_attributes) }
  let(:simple_model_attributes) { { name: 'test' } }

  describe SimpleModel, type: :model do
    it { is_expected.to callback(:validate_associations).before(:validation) }
    it { is_expected.to validate_presence_of(:name) }
  end

  class ComplexModel < VirtusModel::Base
    attribute :model, SimpleModel
    attribute :models, Array[SimpleModel]
    validates :model, presence: true
    validates :models, presence: true
  end

  let(:complex_model) { ComplexModel.new(complex_model_attributes) }
  let(:complex_model_attributes) do
    {
      model: simple_model_attributes,
      models: [simple_model_attributes]
    }
  end

  describe ComplexModel, type: :model do
    it { is_expected.to callback(:validate_associations).before(:validation) }
    it { is_expected.to validate_presence_of(:model) }
    it { is_expected.to validate_presence_of(:models) }
  end

  class InheritedModel < ComplexModel
    attribute :name, String
  end

  describe InheritedModel, type: :model do
    it { is_expected.to callback(:validate_associations).before(:validation) }
    it { is_expected.to validate_presence_of(:model) }
    it { is_expected.to validate_presence_of(:models) }
  end

  class CallbackModel < ComplexModel
    after_validation :child_callback
  end

  describe CallbackModel, type: :model do
    before(:example) { allow(subject).to receive(:child_callback) }
    it { is_expected.to callback(:validate_associations).before(:validation) }
    it { is_expected.to callback(:child_callback).after(:validation) }
  end

  describe '.attribute?' do
    context SimpleModel do
      subject { SimpleModel }

      it { expect(subject.attribute?(:name)).to be(true) }
      it { expect(subject.attribute?(:other)).to be(false) }
    end

    context ComplexModel do
      subject { ComplexModel }

      it { expect(subject.attribute?(:model)).to be(true) }
      it { expect(subject.attribute?(:models)).to be(true) }
      it { expect(subject.attribute?(:other)).to be(false) }
    end
  end

  describe '.association?' do
    context SimpleModel do
      subject { SimpleModel }

      it { expect(subject.association?(:name)).to be(false) }
      it { expect(subject.association?(:other)).to be(false) }
    end

    context ComplexModel do
      subject { ComplexModel }

      it { expect(subject.association?(:model)).to be(true) }
      it { expect(subject.association?(:models)).to be(true) }
      it { expect(subject.association?(:other)).to be(false) }
    end
  end

  describe '.associations' do
    context SimpleModel do
      subject { SimpleModel }

      it { expect(subject.associations).to eq([]) }
    end

    context ComplexModel do
      subject { ComplexModel }

      it { expect(subject.associations).to eq([:model, :models]) }
      it { expect(subject.associations(:one)).to eq([:model]) }
      it { expect(subject.associations(:many)).to eq([:models]) }
    end
  end

  describe '#initialize' do
    context SimpleModel do
      subject { SimpleModel.new(attributes) }

      context 'attributes are blank' do
        let(:attributes) { nil }
        it { expect(subject.attributes).to eq(name: nil) }
      end

      context 'attributes are present' do
        let(:attributes) { { name: 'test', other: 'test' } }
        it { expect(subject.attributes).to eq(name: 'test') }
        it { expect(subject.attributes).not_to eq(other: 'test') }
      end
    end

    context ComplexModel do
      subject { ComplexModel.new(attributes) }

      context 'attributes are blank' do
        let(:attributes) { nil }
        it { expect(subject.attributes).to eq(model: nil, models: []) }
      end

      context 'attributes are present' do
        let(:attributes) { { model: model, models: [model], other: 'test' } }
        let(:model) { { name: 'test' } }
        it { expect(subject.export[:model]).to eq(model) }
        it { expect(subject.export[:models]).to eq([model]) }
        it { expect(subject.attributes).not_to eq(other: 'test') }
      end
    end
  end

  describe '#assign_attributes' do
    context SimpleModel do
      subject { SimpleModel.new.assign_attributes(attributes) }

      context 'hash' do
        let(:attributes) { { name: 'test', other: 'test' } }
        it { expect(subject.attributes).to include(name: 'test') }
        it { expect(subject.attributes).not_to include(other: 'test') }
      end

      context 'object' do
        let(:attributes) { simple_model }
        it { expect(subject == simple_model).to be(true) }
      end
    end

    context ComplexModel do
      subject { ComplexModel.new.assign_attributes(attributes) }

      context 'hash' do
        let(:attributes) { { model: model, models: [model], other: 'test' } }
        let(:model) { { name: 'test', other: 'test' } }
        it { expect(subject.attributes[:model]).to eq(SimpleModel.new(model)) }
        it { expect(subject.attributes[:models]).to eq([SimpleModel.new(model)]) }
        it { expect(subject.attributes).not_to include(other: 'test') }
      end

      context 'object' do
        let(:attributes) { complex_model }
        it { expect(subject == complex_model).to be(true) }
      end
    end
  end

  describe '#update' do
    let!(:valid) { subject.update(attributes) }

    context SimpleModel do
      subject { SimpleModel.new }

      context 'attributes are blank' do
        let(:attributes) { nil }
        it { expect(subject.export).to eq(name: nil) }
        it { expect(valid).to be(false) }
      end

      context 'attributes are invalid' do
        let(:attributes) { { name: '' } }
        it { expect(subject.export).to eq(name: '') }
        it { expect(valid).to be(false) }
      end

      context 'attributes are valid' do
        let(:attributes) { simple_model_attributes }
        it { expect(subject.export).to eq(name: 'test') }
        it { expect(valid).to be(true) }
      end
    end

    context ComplexModel do
      subject { ComplexModel.new }

      context 'attributes are blank' do
        let(:attributes) { nil }
        it { expect(subject.export).to eq(model: nil, models: []) }
        it { expect(valid).to be(false) }
      end

      context 'attributes are invalid' do
        let(:attributes) { { model: {} } }
        it { expect(subject.export[:model]).to include(name: nil) }
        it { expect(valid).to be(false) }
      end

      context 'attributes are valid' do
        let(:attributes) { complex_model_attributes }
        it { expect(subject.export[:model]).to include(name: 'test') }
        it { expect(valid).to be(true) }
      end
    end
  end

  describe '#==' do
    context SimpleModel do
      subject { simple_model }

      context 'equal hash' do
        let(:other) { subject.dup.export }
        it { expect(subject == other).to be(true) }
      end

      context 'equal object' do
        let(:other) { subject.dup }
        it { expect(subject == other).to be(true) }
      end

      context 'unequal hash' do
        let(:other) { subject.dup.export.merge(name: 'test2') }
        it { expect(subject == other).to be(false) }
      end

      context 'unequal object' do
        let(:other) { subject.dup.assign_attributes(name: 'test2') }
        it { expect(subject == other).to be(false) }
      end
    end

    context ComplexModel do
      subject { complex_model }

      context 'equal hash' do
        let(:other) { subject.dup.export }
        it { expect(subject == other).to be(true) }
      end

      context 'equal object' do
        let(:other) { subject.dup }
        it { expect(subject == other).to be(true) }
      end

      context 'unequal hash' do
        let(:other) { subject.dup.export.merge(models: { name: 'test2' }) }
        it { expect(subject == other).to be(false) }
      end

      context 'unequal object' do
        let(:other) { subject.dup.assign_attributes(models: [{ name: 'test2' }]) }
        it { expect(subject == other).to be(false) }
      end
    end
  end

  describe '#export' do
    context SimpleModel do
      subject { simple_model }

      it { expect(subject.export).to eq(simple_model_attributes) }
    end

    context ComplexModel do
      subject { complex_model }

      it { expect(subject.export).to eq(complex_model_attributes) }
    end
  end

  describe '#to_hash' do
    context SimpleModel do
      subject { simple_model }

      it { expect(subject.to_hash).to eq(subject.export) }
      it { expect(subject.to_h).to eq(subject.to_hash) }
      it { expect(subject.as_json).to eq(subject.to_hash.deep_stringify_keys) }
    end

    context ComplexModel do
      subject { complex_model }

      it { expect(subject.to_hash).to eq(subject.export) }
      it { expect(subject.to_h).to eq(subject.to_hash) }
      it { expect(subject.as_json).to eq(subject.to_hash.deep_stringify_keys) }
    end
  end

  describe '#to_json' do
    context SimpleModel do
      subject { simple_model }

      it { expect(subject.to_json).to eq(subject.export.to_json) }
    end

    context ComplexModel do
      subject { complex_model }

      it { expect(subject.to_json).to eq(subject.export.to_json) }
    end
  end

  describe '#validate' do
    before { subject.validate }

    context SimpleModel do
      context 'valid' do
        subject { simple_model }

        it { expect(subject.valid?).to be(true) }
        it { expect(subject.errors).to be_blank }
      end

      context 'invalid' do
        subject { simple_model.assign_attributes(name: '') }

        it { expect(subject.valid?).to be(false) }
        it { expect(subject.errors.messages).to include(name: ["can't be blank"]) }
      end
    end

    context ComplexModel do
      context 'valid' do
        subject { complex_model }

        it { expect(subject.valid?).to be(true) }
        it { expect(subject.errors).to be_blank }
      end

      context 'invalid' do
        subject { complex_model.assign_attributes(model: {}, models: [{}]) }

        it { expect(subject.valid?).to be(false) }
        it { expect(subject.errors.messages).to include(:"model[name]" => ["can't be blank"]) }
        it { expect(subject.errors.messages).to include(:"models[0][name]" => ["can't be blank"]) }
      end
    end
  end

  describe '#to_json' do
    context SimpleModel do
      subject { simple_model }

      it { expect(subject.to_json).to eq(subject.export.to_json) }
    end

    context ComplexModel do
      subject { complex_model }

      it { expect(subject.to_json).to eq(subject.export.to_json) }
    end
  end
end
