# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    module Extensions
      module Object
        include ActionView::Helpers::NumberHelper
  
        def nil_as_string
          if self.blank? then "" else self end
        end
  
        def is_valid_number?
          self.is_valid_float? 
        end
  
        def is_valid_integer?
          self.is_a?(Integer) || (!self.blank? && /^([+-]?)(\d+)$/.match(self.to_s.strip) != nil)
        end

        def is_valid_float?
          self.is_a?(Float) || (!self.blank? && /^([+-]?)(\d+)([.,]\d*)?$/.match(self.to_s.strip) != nil)
        end

        def is_valid_boolean?
          self.is_a?(TrueClass) || self.is_a?(FalseClass) || self.is_a?(NilClass) || /^(1|0|true|false|yes|no|t|f|y|n)$/i.match(self.to_s.strip) != nil
        end

        def ensure_array
          self.is_a?(Array) ? self : [self]
        end
          
        def to_float
          self.is_valid_float? ? Kernel.Float(self.respond_to?(:gsub) ? self.gsub(",", ".") : self) : 0.0
        end
  
        def to_integer
          self.is_valid_integer? ? Kernel.Integer(self, self.is_a?(String) ? 10 : 0) : 0
        end
  
        def to_boolean
          (self.is_a?(TrueClass) || /^(1|on|true|yes|t|y)$/i.match(self.to_s.strip)) ? true : false
        end
  
        def round_to_precision(prec = 2)
          number_with_precision(self, :precision => prec) 
        end
  
        def format_number(prec = 2, decimal_separator = ",", add_string = "€", k_separator = ".")
          number_to_currency(self, 
            {
              :precision => prec, 
              :separator => decimal_separator, 
              :delimiter => k_separator, 
              :format => if add_string.blank? then "%n" else "%n %u" end, 
              :unit => if add_string.blank? then "" else add_string.strip end
            })
        end

        def format_boolean
          self.to_boolean ? "Yes" : "No"
        end
  
        def dump
          raise Exception.new("DUMP: #{self.to_json}")
        end
      end

      module True
        def to_i
          1
        end
      end

      module False
        def to_i
          0
        end
      end

      module String
        def remove_accents
          self.mb_chars.normalize(:kd).gsub(/[^\-x00-\x7F]/n, '').to_s
        end
  
        def untitleize
          self.downcase.gsub(" ", "-") 
        end
  
        def replace_ampersands
          self.gsub(/&amp;(\S+);/, "&\\1;") 
        end
      end

      module Hash
        def method_missing(method, *arg)
          self[method.to_sym] || self[method.to_s] 
        end

        def respond_to?(method)
          self.has_key?(method.to_sym) || self.has_key?(method.to_s)
        end
      end

      module Pathname
        def components
          rv = []
          self.each_filename do |p| rv << p end
          rv
        end
      end

      module DateTime
        module ClassMethods
          def months
            i = 0
            months = localized_months
            months.keys.collect do |k|
              i+= 1
              {:value => i.to_s.rjust(2, "0"), :description => months[k][0, 3]}
            end
          end

          def localized_months
            {"January" => "January", "February" => "February",  "March" => "March",  "April" => "April",  "May" => "May",  "June" => "June",
              "July" => "July", "August" => "August",  "September" => "September",  "October" => "October",  "November" => "November", "December" => "December"}
          end

          def localized_days
            {"Sunday" => "Sunday", "Monday" => "Monday", "Tuesday" => "Tuesday", "Wednesday" => "Wednesday", "Thursday" => "Thursday", "Friday" => "Friday", "Saturday" => "Saturday"}
          end
        
          def custom_format(key="date")
            {
              "date" => "%d/%m/%Y",
              "time" => "%H:%M:%S",
              "date-8601" => "%Y-%m-%d",
              "date-time-8601" => "%Y-%m-%d %H:%M:%S",
              "iso-8601" => "%FT%T%z",
              "update" => "%d/%m/%Y %H:%M"
            }.fetch(key.to_s, "%d/%m/%Y")
          end

          def years(offset = 10, also_future = true)
            rv = []
            y = Date.today.year
            (y - offset..(also_future ? y + offset : y)).each do |year| rv << {:value => year} end
            rv
          end
  
          def localized_short_months
            rv = {}
            self.localized_months.each do |k,v| rv[k[0, 3]] = v[0, 3] end
            rv
          end
  
          def localized_short_days
            rv = {}
            self.localized_days.each do |k,v| rv[k[0, 3]] = v[0, 3] end
            rv
          end

          def easter(year = nil)
            day = 1
            month = 3
            year = Date.today.year unless year.is_valid_integer?

            # GAUSS METHOD
            m = 24
            n = 5
            a = year % 19
            b = year % 4
            c = year % 7
            d = ((19 * a) + m) % 30
            e = ((2 * b) + (4 * c) + (6 * d) + n) % 7

            if d + e < 10 then
              day = d + e + 22
            else
              day = d + e - 9
              month = 4
            end

            if day == 26 && month == 4 then
              day = 19
            elsif day == 25 && month == 4 && d == 28 && e == 6 && a > 10 then
              day = 18
            end
            #END

            Date.civil(year, month, day) 
          end
        end
        
        def self.included(receiver)
          receiver.extend ClassMethods
        end
          
        def lstrftime(format = nil)
          format = self.class.custom_format($1) if format =~ /^custom::(.+)/    
          unlocal = self.strftime(format || self.class.custom_format("update"))
    
          # CHANGE LONG DAYS AND MONTHS
          unlocal.gsub!(/(#{self.class.localized_months.keys.join("|")})/i) do |s| self.class.localized_months[$1] end
          unlocal.gsub!(/(#{self.class.localized_days.keys.join("|")})/i) do |s| self.class.localized_days[$1] end

          # CHANGE SHORT DAYS AND MONTHS
          unlocal.gsub!(/(#{self.class.localized_short_months.keys.join("|")})/i) do |s| self.class.localized_short_months[$1] end
          unlocal.gsub!(/(#{self.class.localized_short_days.keys.join("|")})/i) do |s| self.class.localized_short_days[$1] end

          unlocal
        end
  
        def padded_month
          self.month.to_s.rjust(2, "0") 
        end
  
        def in_months
          ((self.year - 1) % 2000) * 12 + self.month
        end
      end
    end
  end
end

module Math
  def self.max(a, b)
    if a > b then a else b end
  end

  def self.min(a, b)
    if a < b then a else b end
  end
end

if defined?(ActiveRecord) then
  class ActiveRecord::Base
    def self.table_prefix
      p = ActiveRecord::Base.configurations[Rails.env]["table_prefix"]
      !p.blank? ? p + "_" : ""
    end

    def self.table_suffix
      p = ActiveRecord::Base.configurations[Rails.env]["table_suffix"]
      !p.blank? ? p + "_" : ""
    end

    def self.set_table_name(value = nil, &block)  
      define_attr_method :table_name, "#{ActiveRecord::Base.table_prefix}#{value}#{ActiveRecord::Base.table_suffix}", &block  
    end

    def self.find_or_create(oid, attributes = nil)
      begin
        self.find(oid)
      rescue ActiveRecord::RecordNotFound
        self.new(attributes)
      end
    end

    def self.safe_find(oid)
      begin
        rv = self.find(oid)
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end

    def self.random
      c = self.count
      c != 0 ? self.find(:first, :offset => rand(c)) : nil
    end

    def self.per_page
      25
    end
  end
end