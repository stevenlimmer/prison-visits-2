require 'rails_helper'
require_relative '../metrics/shared_examples_for_metrics'

RSpec.feature 'Metrics', js: true do
  include ActiveJobHelper
  let(:email_address) { 'joe@example.com' }
  let(:sso_response) do
    {
      'uid' => '1234-1234-1234-1234',
      'provider' => 'mojsso',
      'info' => {
        'first_name' => 'Joe',
        'last_name' => 'Goldman',
        'email' => email_address,
        'permissions' => [
          { 'organisation' => EstateSSOMapper::DIGITAL_ORG, roles: [] }
        ],
        'links' => {
          'profile' => 'http://example.com/profile',
          'logout' => 'http://example.com/logout'
        }
      }
    }
  end

  before do
    allow(VisitorMailer).to receive(:rejected).and_return(double('Mailer', deliver_later: nil))
    OmniAuth.config.add_mock(:mojsso, sso_response)
  end

  context 'when overdue' do
    let(:date_today) { Time.zone.local(2016, 2, 8) }
    let!(:visits) do
      book_a_luna_visit_late
      reject_a_luna_visit_late
      book_a_mars_visit_late
      luna_visit
    end

    include_examples 'when creating visits with dates'
    # Shared examples are booked within the first week of February, 2106. The
    # controller tracks one week behind the current date.

    before do
      visit(metrics_path(locale: 'en', range: 'all_time'))
    end

    it 'has the correct overdue and waiting values' do
      expect(page).to have_selector('.luna-overdue', text: 2)
      expect(page).to have_selector('.mars-overdue', text: 1)
      expect(page).to have_selector('.luna-waiting', text: 1)
    end
  end

  context 'with rejections' do
    include_examples 'when creating rejections with dates'

    context 'when all the time' do
      before do
        luna_visits_with_dates

        visit(metrics_path(locale: 'en', range: 'all_time'))
      end

      it 'has the correct rejection percentages' do
        # These will track the spec in spec/metrics/rejections_spec.rb
        expect(page).to have_selector('.luna-total', text: 10)
      end

      it 'sends en email with a csv attachment', driver: :rack_test do
        click_on 'Email latest confirmed bookings (CSV)'
        expect(email_address).
          to receive_email.
          with_subject(/Confirmed bookings \(CSV\)/).
          with_attachment('confirmed_bookings.csv')
      end
    end
  end
end
