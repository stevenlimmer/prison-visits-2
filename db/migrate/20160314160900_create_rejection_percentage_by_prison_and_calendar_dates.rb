class CreateRejectionPercentageByPrisonAndCalendarDates < ActiveRecord::Migration[4.2]
  def change
    create_view :rejection_percentage_by_prison_and_calendar_dates
  end
end
