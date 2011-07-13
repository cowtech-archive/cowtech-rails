# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    module Helpers
      module CRUDHelper
        attr_reader :data_bounds
        attr_reader :record

        def crud_get_data
          @crud_data ||= {}
        end

        def crud_get_class(data = nil)
          data = self.crud_get_data if !data
          data[:class].constantize
        end

        def crud_get_records(data)
          data = self.crud_get_data if !data
          data[:records]
        end

        def crud_query_get_params(data = nil)
          data = self.crud_get_data if !data
          data[:query_params]
        end

        def crud_get_sort_order(data = nil)
          data = self.crud_get_data if !data
          data[:sort_order]
        end

        def crud_has_data?(data = nil)
          data = self.crud_get_data if !data
          data[:data_bounds].total > 0
        end

        def crud_get_pager_data(data = nil)
          data = self.crud_get_data if !data
          data[:pager_data]
        end

        def crud_get_data_bounds(data = nil)
          data = self.crud_get_data if !data
          data[:data_bounds]
        end

        def crud_set_data(data)
          @crud_data = data
        end

        def crud_set_class(data, table = "")
          data = self.crud_get_data if !data
          data[:class] = table
        end

        def crud_set_records(data, records = nil)
          data = self.crud_get_data if !data
          data[:records] = records
        end

        def crud_finalize_read(data = nil, records = nil, parameter = :count, per_page = nil)
          data = self.crud_get_data if !data
          records = self.crud_get_records(data) if !records
          self.crud_calculate_data_bounds(data, records, per_page || params[parameter])
          data[:pager_data] = records.paginate(:page => data[:data_bounds].page, :per_page => data[:data_bounds].per_page, :total_entries => data[:data_bounds].total) if records.respond_to?(:paginate)
        end  

        def crud_query_initialize(data = nil, force = false)
          data = self.crud_get_data if !data
          data[:query_expr] = [] if !data[:query_expr] || force
          data[:query_params] = {} if !data[:query_params] || force    
          data[:query_initialized] = true
        end

        def crud_query_get(data = nil, query = nil)
          data = self.crud_get_data if !data
          self.crud_query_initialize(data) if !data[:query_initialized]
          query = data[:query_expr] if !query

          query.count.times do |i| query[i] = "(#{query[i]})" end
          query.join(" AND ")
        end

        def crud_query_dump(data = nil)
          data = self.crud_get_data if !data
          self.crud_query_initialize(data) if !data[:query_initialized]
          raise Exception.new("QUERY: #{data[:query_expr]}\nPARAMS: #{data[:query_params].to_json}")
        end

        def crud_query_add_condition(data, expr, params = {})
          data = self.crud_get_data if !data
          self.crud_query_initialize(data) if !data[:query_initialized]

          expr = [expr] if !expr.respond_to?(:each)    
          expr.each do |e| data[:query_expr] << e end

          data[:query_params].merge!(params)
        end

        def crud_query_parse_search(search)
          search = "(@#{search}@)"
          search.gsub!(/(\s+(AND|OR|NOT)\s+)/, "@) \\1 (@")

          # SUBSTITUTE PARAMETERS
          i = -1
          parameters = {}
          search.gsub!(/@(.+?)@/) do |s|
            i += 1

            key = "search_parameter_#{i}".to_sym
            val = $1

            # HANDLE LINE MARKERS
            if val =~ /^\^.+\$$/ then
              val = "#{val.gsub(/^\^(.+)\$$/, "\\1").strip}"
            elsif val =~ /^\^/ then
              val = "#{val.gsub(/^\^/, "").strip}%"
            elsif val =~ /\$$/ then
              val = "%#{val.gsub(/\$$/, "").strip}"
            else
              val = "%#{val.strip}%"          
            end

            parameters[key] = val
            "@FIELD@ LIKE :#{key}"
          end

          [search, parameters]
        end

        def crud_handle_search(data, *fields)
          data = self.crud_get_data if !data
          self.crud_handle_extended_search(data, fields)
        end

        def crud_handle_extended_search(data, fields, externals = nil, args = nil, parameter = :search)
          data = self.crud_get_data if !data
          self.crud_query_initialize(data) if !data[:query_initialized]
          parameter = :search if !parameter

          self.crud_query_add_condition(data, "(#{self.crud_get_class(data).table_name}.#{self.crud_get_class(data).deleted_column} IS NULL)", {}) if !data[:skip_deleted]

          # GET QUERY
          args = params[parameter] if !args

          if !args.blank? then
            search, parameters = self.crud_query_parse_search(args)

            # BUILD QUERY
            data[:query_params].merge!(parameters)
            search_query = []
            fields.each do |field| search_query << "(#{search.gsub("@FIELD@", "#{self.crud_get_class(data).table_name}.#{field.to_s}")})" end

            # ADD OPTIONAL DATA
            if externals then
              externals.each do |external|
                external_query = ""
    
                if !external[:manual] then
                  external_conds = []
                  external.fetch(:fields, []).each do |external_field| external_conds << "(#{search.gsub("@FIELD@", "#{external[:table]}.#{external_field.to_s}")})" end
                  external_field = external.fetch(:external_field, "id")
                  external_query = "(#{external.fetch(:field, "id")} IN (SELECT #{external.fetch(:external_field, "id")} FROM #{external[:table]} WHERE #{external_conds.join(" OR ")}))" 
                else
                  external_conds = []
                  raw_external_conds = []

                  external.fetch(:fields, []).each do |external_field| 
                    external_conds << "(#{search.gsub("@FIELD@", "#{external[:table]}.#{external_field.to_s}")})" 
                    raw_external_conds << "(#{search.gsub("@FIELD@", "#{external_field.to_s}")})"
                  end

                  external_query = external[:query].gsub("@SEARCH@", external_conds.join(" OR "))
                  external_query = external[:query].gsub("@RAW_SEARCH@", raw_external_conds.join(" OR "))
                end
  
                search_query << external_query
              end
            end

            self.crud_query_add_condition(data, search_query.join(" OR "))      
          end

          [data[:query_expr], data[:query_params]]
        end

        def crud_handle_sorting(data, default_sorting, sort_data, sort_expression = "@PLACEHOLDER@, updated_at DESC")
          data = self.crud_get_data if !data
          data[:sort_data] = sort_data
          sort = self.crud_get_sort_param(default_sorting, (sort_data || {}).keys)
          data[:sort] = "#{sort.what}-#{sort.how.downcase}"
          data[:sort_order] = sort_expression.gsub("@PLACEHOLDER@", "#{sort.what} #{sort.how}")
        end

        def crud_get_form_data
          @record
        end
        
        def crud_form_header(female = false)
          if self.crud_get_form_data.new_record? then 
            "Create new"
          else
            "Edit"
          end
        end

        def crud_form_submit_label
          if self.crud_get_form_data.new_record? then "Create" else "Edit" end
        end

        def crud_get_page_param(key = :page, upperbound = -1)
          page = params[key]
          page = if params[key].is_valid_integer? then params[key].to_integer else 1 end
          page = 1 if page < 1
          page = upperbound if (upperbound > 0 and page > upperbound)
          page
        end

        def crud_get_sort_param(default, valids = [])
          sort_by = get_param(:sort_by, default)
          mo = /^(?<what>[a-z0-9_]+)-(?<how>asc|desc)$/i.match(sort_by)
          mo = /^(?<what>[a-z0-9_]+)-(?<how>asc|desc)$/i.match(default) if !mo || !(valids || []).include?(mo["what"])

          sf = sort_by.split("-")
          rv = OpenStruct.new({:what => mo["what"], :how => mo["how"].upcase})

          # ADAPT SOME PARAMETERS
          rv.what = "status_id" if rv.what == "status"

          rv
        end

        def crud_calculate_data_bounds(data, records = nil, per_page = nil)
          data = self.crud_get_data if !data
          records = data[:records] if !records
          bounds = OpenStruct.new({:total => 0, :first => 0, :last => 0, :pages => 0, :page => 1, :per_page => 1})

          if records != nil && records.count > 0 then
            per_page = (if per_page.is_valid_integer? then per_page else records[0].class.per_page end).to_integer
            per_page = records.count if per_page < 1
            bounds.total = records.count
            bounds.per_page = per_page
            bounds.pages = (bounds.total.to_f / bounds.per_page).ceil
            bounds.page = self.crud_get_page_param(:page, bounds.pages)

            base = ((bounds.page - 1) * bounds.per_page)
            bounds.first = base + 1
            bounds.last = base + bounds.per_page
            bounds.last = bounds.total if bounds.last > bounds.total
          end

          data[:data_bounds] = bounds
        end

        def crud_update_params
          blacklist = ["controller", "action", "id"]
          session["params-#{self.location_name}"] = (params.delete_if {|k,v| blacklist.include?(k) || params[k].is_a?(Tempfile)})
        end

        def crud_yesno
          [OpenStruct.new(:value => true, :label => "Sì"), OpenStruct.new(:value => false, :label => "No")]
        end

        def crud_end_write_action(additional = nil, absolute = false)
          redirect_to self.crud_end_write_action_url(additional, absolute)
        end

        def crud_end_write_action_url(additional = nil, absolute = false)
          rp = {}

          if !absolute then
            rp = session["params-#{self.location_name(:index)}"] || {}
            rp[:action] = :index
          end

          if additional != nil then
            additional.each do |k, v| rp[k] = v end
          end

          url_for(rp)
        end

        def crud_delete(table, id, only_check = false)
          record = table.constantize.safe_find(id.to_integer)

          if record then
            if only_check then
              record.deletable?
            else
              record.delete
            end
          else
            false
          end
        end
      end
    end
  end
end