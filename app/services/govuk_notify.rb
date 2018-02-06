require 'notifications/client'

class GovukNotify


  def send
    client.send_email(
      email_address: email_address,
      template_id: template_id,
      personalisation: {
        # body: 'app/view'
      },
      reference: "your_reference_string",
      email_reply_to_id: email_reply_to_id
    )
  end

    private

    def client
      @client ||= Notifications::Client.new(api_key)
    end

    def api_key
      Rails.application.config.govuk_notify_key
    end

    def template_id
      '1ff175df-e277-4e90-8aa7-1f6310426ab4'
    end
  end
