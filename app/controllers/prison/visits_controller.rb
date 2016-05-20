class Prison::VisitsController < ApplicationController
  helper CalendarHelper
  before_action :authorize_prison_request

  def process_visit
    @booking_response = BookingResponse.new(visit: visit)
  end

  def update
    @booking_response = BookingResponse.new(booking_response_params)
    if @booking_response.valid?
      BookingResponder.new(@booking_response).respond!
    else
      render :process_visit
    end
  end

  def show
    @visit = visit
  end

private

  def visit
    Visit.find(params[:id])
  end

  def booking_response_params
    params.
      require(:booking_response).
      permit(
        :visitor_banned, :visitor_not_on_list,
        :selection, :reference_no, :closed_visit,
        :allowance_will_renew, :allowance_renews_on,
        :privileged_allowance_available, :privileged_allowance_expires_on,
        unlisted_visitor_ids: [], banned_visitor_ids: []
      ).
      merge(visit: visit)
  end
end
