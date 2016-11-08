require "rails_helper"

RSpec.describe AccessibleDate do
  let(:attributes) { { year: '2017', month: '12', day: '25' } }
  subject { described_class.new(attributes) }

  it { is_expected.to be_valid }

  describe 'validations' do
    context 'with an invalid date' do
      let(:attributes) { { year: '2017', month: '13', day: '25' } }

      it { is_expected.to_not be_valid }
    end
  end

  describe 'to_date' do
    it 'is serialized correctly' do
      expect(subject.to_date).to eq(Date.new(2017, 12, 25))
    end
  end
end