# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    module Helpers
      module ApplicationHelper
        def application_info
          @application_info = YAML.load_file(Rails.root + "config/application_info.yml") unless @application_info
          @application_info
        end

        def location_name(action = nil, controller = nil)
          controller = self.controller_name unless controller
          action = self.action_name unless action
          "#{controller}##{action}"
        end

        def additional_tag(what = :js, *args)
          if what == :js then
            args.insert(0, "app/#{self.controller_name}.js")
            javascript_include_tag(*args)
          elsif what == :css then
            args.insert(0, "#{self.controller_name}.css")
            stylesheet_link_tag(*args)
          end
        end

        def get_data(key = nil, default = "")
          rv = default

          unless @outputdata.nil? then
            rv = @outputdata[key] unless @outputdata[key].nil?
          end

          rv
        end

        def get_param(key, default = nil)
          if params[key].blank? then default else params[key] end
        end

        def _normalize_type(format = nil)
          if format != nil then
            request.format = format
          else
            request.format = :text if request.format != :json
          end
        end

        def setup_json_response(type = :base)
          ApplicationController.setup_json_response(type)
        end

        def custom_respond_with(data, format = nil)
          return if performed?

          self._normalize_type(format)

          if request.format == :text then
              render :text => data
          elsif request.format == :json then
              render :json => data
          end
        end

        def debug(what, type = :json)
          msg = ""

          if type == :json then 
            begin
              msg = JSON.pretty_generate(what) 
            rescue Exception => e
              msg = what.to_json
            end
          else 
            msg = what.inspect 
          end

          rv = ""
          case type.to_sym
            when :json
              rv = render_to_string(:json => msg)
            else
              rv = render_to_string(:text => msg)
          end

          self.response_body = rv
        end
      end
    end
  end
end