require 'rails_helper'

RSpec.describe ApiPrisonerChecker do
  subject(:instance) do
    described_class.new(noms_id: noms_id, date_of_birth: date_of_birth)
  end

  let(:noms_id) { 'A1234BC' }
  let(:date_of_birth) { Time.zone.today }

  describe '#valid?' do
    context 'when the api is disabled' do
      before do
        switch_off_api
      end

      it { is_expected.to be_valid }
    end

    context 'when the api is enabled' do
      context 'when the check is disabled for public' do
        before do
          switch_off(:nomis_public_prisoner_check_enabled)
        end

        it { is_expected.to be_valid }
      end

      context 'when the api is working' do
        before do
          switch_on(:nomis_public_prisoner_check_enabled)
          mock_nomis_with(:lookup_active_offender, offender)
        end

        describe 'when the offender is found' do
          let(:offender) { Nomis::Offender.new(id: 'some_id', noms_id: 'a_noms_id') }

          context 'with a valid establishment' do
            let(:establishment) { Nomis::Establishment.new(code: 'a_code') }

            before do
              mock_nomis_with(:lookup_offender_location, establishment)
            end

            it { is_expected.to be_valid }
          end

          context 'when fetching the establishment returns an APIError' do
            before do
              simulate_api_error_for(:lookup_offender_location)
            end

            it { is_expected.not_to be_valid }
          end
        end

        describe 'when the offender is not found' do
          let(:offender) { Nomis::NullOffender.new(api_call_successful: true) }

          it { is_expected.not_to be_valid }
        end
      end

      describe "when the api call fails" do
        before do
          switch_on(:nomis_public_prisoner_check_enabled)
          expect_any_instance_of(Nomis::Client).
            to receive(:get).and_raise(Nomis::APIError)
        end

        it { is_expected.to be_valid }
      end
    end
  end

  describe '#error' do
    let(:errors) { ['something'] }
    let(:validator) { instance_double(PrisonerValidation) }

    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
      expect(subject).to receive(:prisoner_validation).and_return(validator)
      expect(validator).to receive(:errors).and_return(base: errors)
    end

    it 'returns the error from the validator' do
      expect(subject.error).to eq('something')
    end
  end
end
