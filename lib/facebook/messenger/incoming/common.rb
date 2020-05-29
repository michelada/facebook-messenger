module Facebook
  module Messenger
    module Incoming
      # Common attributes for all incoming data from Facebook.
      module Common
        attr_reader :messaging

        def initialize(messaging)
          @messaging = messaging
        end

        def sender
          { 'id' => @messaging['sender']['id'] }
        end

        def recipient
          @messaging['recipient']
        end

        def sent_at
          Time.at(@messaging['timestamp'] / 1000)
        end

        def typing_on
          payload = {
            recipient: sender,
            sender_action: 'typing_on'
          }

          deliver(payload)
        end

        def typing_off
          payload = {
            recipient: sender,
            sender_action: 'typing_off'
          }

          deliver(payload)
        end

        def mark_seen
          payload = {
            recipient: sender,
            sender_action: 'mark_seen'
          }

          deliver(payload)
        end

        def reply(message)
          payload = {
            recipient: sender,
            message: message,
            message_type: Facebook::Messenger::Bot::MessageType::RESPONSE
          }

          deliver(payload)
        end

        def deliver(payload)
          time = secret_time
          proof = secret_proof(time)

          Facebook::Messenger::Bot.deliver(payload,
                                           access_token: access_token,
                                           appsecret_proof: proof,
                                           appsecret_time: time)
        end

        def access_token
          Facebook::Messenger.config.provider.access_token_for(recipient)
        end

        def app_secret
          Facebook::Messenger.config.provider.app_secret
        end

        def secret_time
          Time.now.to_i.to_s
        end

        def secret_proof(time)
          OpenSSL::HMAC.hexdigest('sha256', app_secret, "#{access_token}|#{time}")
        end
      end
    end
  end
end
