# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    module Models
      class EMail < ActionMailer::Base
        def self.setup(method = :smtp)
          rv = YAML.load_file(Rails.root + "config/email.yml")

          ActionMailer::Base.raise_delivery_errors = true
          ActionMailer::Base.charset = "utf-8"
          ActionMailer::Base.delivery_method = method

          case method
            when :fail_test
              raise ArgumentError
            when :smtp
              ActionMailer::Base.smtp_settings = rv[:smtp]
          end

          rv
        end

        def setup(method = :smtp)
          @configuration = EMail.setup(method) if !@configuration
          @configuration
        end

        def generic(*args)
          self.setup

          # OTTENIAMO GLI ARGOMENTI
          args = (if args.is_a?(Hash) then args else args[0] end).delete_if { |k,v| v.blank? }

          # AGGIUSTIAMO REPLY TO
          args[:reply_to] = args[:from] if !args[:reply_to]

          # OTTENIAMO IL BODY
          plain_body = args.delete(:body) || args.delete(:plain_body) || args.delete(:text_body) || args.delete(:plain_text) || args.delete(:text)
          html_body = args.delete(:html_body) || args.delete(:html)

          mail(args) do |format|
            if plain_body then # SE C'E' PLAIN BODY
              format.text do render :text => plain_body end
            end
            if html_body then # SE C'E' HTML
              format.html do render :text => html_body end
            end
          end
        end
      end
    end
  end
end
