# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
	module RubyOnRails
		module Models
			class EMail < ActionMailer::Base
				def self.setup(method = :smtp, config = nil, raise_config_errors = true)
					rv = {}

					if config.is_a?(Hash) then
						rv = config
					else
						begin
							rv = YAML.load_file(config || (Rails.root + "config/email.yml"))
						rescue Exception => e
							raise e if raise_config_errors
							rv = {}
						end
					end

					ActionMailer::Base.raise_delivery_errors = true
					ActionMailer::Base.delivery_method = method

					case method
						when :fail_test
							raise ArgumentError
						when :smtp
							ActionMailer::Base.smtp_settings = rv[:smtp]
					end

					rv
				end

				def setup(method = :smtp, config = nil, raise_config_errors = true)
					@configuration ||= EMail.setup(method, config, raise_config_errors)
				end

				def generic(args)
					# Load configuration
					if !@configuration then
						config = args.delete(:configuration)

						if config.is_a?(Hash) then
							self.setup(config[:method] || args.delete(:method) || :smtp, config)
						else
							self.setup(args.delete(:method) || :smtp, args.delete(:configuration_file))
						end
					end

					# Get arguments and add reply-to
					args = (args.is_a?(Hash) ? args : args[0]).delete_if { |k,v| v.blank? }
					args[:reply_to] = args[:from] if !args[:reply_to]

					# Get body
					plain_body = args.delete(:body) || args.delete(:plain_body) || args.delete(:text_body) || args.delete(:plain_text) || args.delete(:text)
					html_body = args.delete(:html_body) || args.delete(:html)

					mail(args) do |format|
						if plain_body then
							format.text { render text: plain_body }
						end
						if html_body then
							format.html { render text: html_body }
						end
					end
				end
			end
		end
	end
end
