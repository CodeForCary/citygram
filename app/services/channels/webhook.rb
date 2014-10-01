require 'app/services/connection_builder'

module Citygram::Services::Channels
  class Webhook < Base
    def call
      response = connection.post do |conn|
        conn.body = JSON.pretty_generate(body)
      end

      handle_response(response)
    end

    def connection
      Citygram::Services::ConnectionBuilder.json("request.subscription.#{subscription.id}", url: subscription.webhook_url)
    end

    def body
      {
        event: event.attributes,
        subscription: subscription.attributes,
        publisher: event.publisher.attributes
      }
    end

    def handle_response(response)
      case response.status
      when 200..299 # job succeeded
      else # job failed, retry unless retries exhausted
        raise NotificationFailure, "HTTP status code: #{response.status}"
      end
    end
  end
end

Citygram::Services::Channels[:webhook] = Citygram::Services::Channels::Webhook
