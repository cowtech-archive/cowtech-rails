# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module SubdomainFu
  def self.override_only_path?
    true
  end
end

# To enable real SSL
if defined?(Mail) then
  class Mail::SMTP
    def deliver!(mail)

      # Set the envelope from to be either the return-path, the sender or the first from address
      envelope_from = mail.return_path || mail.sender || mail.from_addrs.first
      if envelope_from.blank?
        raise ArgumentError.new('A sender (Return-Path, Sender or From) required to send a message') 
      end

      destinations ||= mail.destinations if mail.respond_to?(:destinations) && mail.destinations
      if destinations.blank?
        raise ArgumentError.new('At least one recipient (To, Cc or Bcc) is required to send a message') 
      end

      message ||= mail.encoded if mail.respond_to?(:encoded)
      if message.blank?
        raise ArgumentError.new('A encoded content is required to send a message')
      end

      smtp = Net::SMTP.new(settings[:address], settings[:port])
      if settings[:tls] || settings[:ssl]
        if smtp.respond_to?(:enable_tls)
          if !settings[:openssl_verify_mode]
            smtp.enable_tls
          else
            openssl_verify_mode = settings[:openssl_verify_mode]
            if openssl_verify_mode.kind_of?(String)
              openssl_verify_mode = "OpenSSL::SSL::VERIFY_#{openssl_verify_mode.upcase}".constantize
            end
            context = Net::SMTP.default_ssl_context
            context.verify_mode = openssl_verify_mode
            smtp.enable_tls(context)
          end        
        end
      elsif settings[:enable_starttls_auto]
        if smtp.respond_to?(:enable_starttls_auto) 
          if !settings[:openssl_verify_mode]
            smtp.enable_starttls_auto
          else
            openssl_verify_mode = settings[:openssl_verify_mode]
            if openssl_verify_mode.kind_of?(String)
              openssl_verify_mode = "OpenSSL::SSL::VERIFY_#{openssl_verify_mode.upcase}".constantize
            end
            context = Net::SMTP.default_ssl_context
            context.verify_mode = openssl_verify_mode
            smtp.enable_starttls_auto(context)
          end
        end
      end
      smtp.start(settings[:domain], settings[:user_name], settings[:password], settings[:authentication]) do |smtp|
        smtp.sendmail(message, envelope_from, destinations)
      end

      self
    end
  end
end