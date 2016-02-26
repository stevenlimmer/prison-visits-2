require 'rails_helper'

RSpec.describe PrisonerStep do
  subject { described_class.new(prison: prison) }

  let(:params) {
    {
      first_name: 'Joe',
      last_name: 'Bloggs',
      date_of_birth: {
        day: '31',
        month: '12',
        year: '1970'
      },
      number: 'a1234bc',
      prison_id: 'uuid'
    }
  }

  it 'does not fail if the date is invalid (anti-regression)' do
    params[:date_of_birth][:month] = '13'
    prisoner_step = described_class.new(params)

    dob = prisoner_step.date_of_birth

    expect(dob).to be_kind_of(UncoercedDate)
    expect(dob.month).to eql(13)
  end
end