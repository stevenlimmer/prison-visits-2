require 'rails_helper'

RSpec.describe Depersonalizer do
  let(:cutoff_date) { Time.zone.now - 30.days }

  context 'when processing prisoners' do
    let!(:prisoner) {
      create(
        :prisoner,
        first_name: 'Oscar',
        last_name: 'Wilde',
        date_of_birth: Date.new(1980, 1, 1),
        number: 'ABC1234'
      )
    }

    it 'anonymises prisoners older than the cutoff date' do
      subject.remove_personal_information(Time.zone.now + 1.day)
      expect(prisoner.reload).to have_attributes(
        first_name: 'REMOVED',
        last_name: 'REMOVED',
        date_of_birth: Date.new(1, 1, 1),
        number: 'REMOVED'
      )
    end

    it 'does not anonymise prisoners newer than the cutoff date' do
      subject.remove_personal_information(Time.zone.now - 1.day)
      expect(prisoner.reload).to have_attributes(
        first_name: 'Oscar',
        last_name: 'Wilde',
        date_of_birth: Date.new(1980, 1, 1),
        number: 'ABC1234'
      )
    end
  end

  context 'when processing visitors' do
    let!(:visitor) {
      create(
        :visitor,
        first_name: 'Ada',
        last_name: 'Lovelace',
        date_of_birth: Date.new(1970, 2, 3)
      )
    }

    it 'anonymises visitors older than the cutoff date' do
      subject.remove_personal_information(Time.zone.now + 1.day)
      expect(visitor.reload).to have_attributes(
        first_name: 'REMOVED',
        last_name: 'REMOVED',
        date_of_birth: Date.new(1, 1, 1)
      )
    end

    it 'does not anonymise visitors newer than the cutoff date' do
      subject.remove_personal_information(Time.zone.now - 1.day)
      expect(visitor.reload).to have_attributes(
        first_name: 'Ada',
        last_name: 'Lovelace',
        date_of_birth: Date.new(1970, 2, 3)
      )
    end
  end

  context 'when processing visits' do
    let!(:visit) {
      create(
        :visit,
        contact_email_address: 'user@example.com',
        contact_phone_no: '0115 4960123'
      )
    }

    it 'anonymises visits older than the cutoff date' do
      subject.remove_personal_information(Time.zone.now + 1.day)
      expect(visit.reload).to have_attributes(
        contact_email_address: 'REMOVED',
        contact_phone_no: 'REMOVED'
      )
    end

    it 'does not anonymise visits newer than the cutoff date' do
      subject.remove_personal_information(Time.zone.now - 1.day)
      expect(visit.reload).to have_attributes(
        contact_email_address: 'user@example.com',
        contact_phone_no: '0115 4960123'
      )
    end
  end
end