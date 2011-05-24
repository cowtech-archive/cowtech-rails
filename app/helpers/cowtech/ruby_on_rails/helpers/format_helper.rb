# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    module Helpers
      module FormatHelper
        def format_field(field, default = nil)
          if field.is_a?(Fixnum) then
            field
          elsif field.is_a?(Float) then
            field.format_number
          elsif field.blank? || field.strip.blank? then
            (if default then default else "Not set" end)
          else
            field
          end
        end

        def currency_class(currency, include_positive = true, include_zero = true)
          color = ""

          if currency > 0 then
            color = "positive" if include_positive
          elsif currency < 0 then
            color = "negative"
          else
            color = "zero" if include_zero
          end

          "class=\"numeric #{color}\""
        end

        def text_class(val, additional = nil)
          "class=\"text #{if additional.blank? then nil else additional end} #{if val.blank? then "unset" else nil end}\""
        end
      end
    end
  end
end