# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    module Helpers
      module MongoidCrudHelper
        attr_accessor :mongo_class
        attr_accessor :records
        attr_accessor :mongo_sort_order
        attr_accessor :mongo_bounds
        attr_accessor :mongo_query
        attr_accessor :mongo_records
        attr_accessor :mongo_pager
  
        def mongo_setup(args = {})
          @mongo_class = args[:class] if args[:class]
          @mongo_class = @mongo_class.constantize if @mongo_class.is_a?(String)
          @mongo_records = []
          @mongo_sort_order = [[:_id, :asc]]
          @mongo_bounds = {:total => 0, :first => 1, :last => 0, :pages => 1, :page => 1, :per_page => 1}
          @mongo_query = self.mongo_reset_query(:also_deleted => args[:also_deleted]) if @mongo_class
        end

        def mongo_has_data?(args = {})
          @mongo_bounds[:total] > 0
        end

        def mongo_calculate_bounds(args = {})
          if @mongo_records.present? then
            @mongo_bounds[:total] = @mongo_records.count
            @mongo_bounds[:per_page] = (args[:per_page].is_integer? ? args[:per_page] : @mongo_records.first.class.per_page).to_integer
            @mongo_bounds[:pages] = (@mongo_bounds[:total].to_f / @mongo_bounds[:per_page]).ceil

            if @mongo_bounds[:per_page] > 0 then
              @mongo_bounds[:page] = self.mongo_get_page_param(:upperbound => @mongo_bounds[:pages])
              base = ((@mongo_bounds[:page] - 1) * @mongo_bounds[:per_page])
              @mongo_bounds[:first] = base + 1
              @mongo_bounds[:last] = [base + @mongo_bounds[:per_page], @mongo_bounds[:total]].min
            else
              @mongo_bounds.merge!(:pages => 1, :page => 1, :first => 1, :last => @mongo_bounds[:total], :per_page => @mongo_bounds[:total])
            end            
          end

          @mongo_bounds
        end

        def mongo_fetch_data(args = {})
          @mongo_records = @mongo_query.order_by(@mongo_sort_order)
          self.mongo_calculate_bounds(args.reverse_merge(:per_page => (args[:per_page] || @mongo_per_page || params[args[:parameter] || :count])))
          @records = @mongo_records.skip(@mongo_bounds[:first] - 1).limit(@mongo_bounds[:per_page])
          @mongo_pager = WillPaginate::Collection.new(@mongo_bounds[:page], @mongo_bounds[:per_page], @mongo_bounds[:total])
        end  

        def mongo_reset_query(args = {})
          klass = args[:class] || @mongo_class
          klass ? (args[:also_deleted] ? klass.where : klass.not_deleted) : nil
        end
        
        def mongo_dump_query(args = {})
          raise Exception.new("QUERY:\n#{@mongo_query.inspect}")
        end

        def mongo_add_query_conditions(args = {})
          (args[:conditions] || []).ensure_array.each do |condition|
            if condition.is_a?(Hash) then
              condition.each_pair do |key, val|
                if key == "$or" then
                  @mongo_query = @mongo_query.any_of(val)
                else
                  @mongo_query = @mongo_query.where({key => val})
                end                 
              end
            end
          end

          @mongo_query = yield(@mongo_query) if block_given?
          @mongo_query
        end

        def mongo_parse_search(search)
          if search.present? then
            # Operate on parenthesis. If unbalanced, no substitution is done
            if search.gsub(/[^(]/mi, "").strip.length == search.gsub(/[^)]/mi, "").strip.length then
              # Split token
              search = search.split(/(\s(AND|OR)\s)|([\(\)])/).select{|t| !t.empty? && t !~ /^(AND|OR)$/}

              # Replace tokens
              search = search.collect { |token|
                  case token
                  when /[\(\)]/ then # No replace
                    token
                  when /\sAND\s/ then
                    "(.+)"
                  when /\sOR\s/ then
                    "|"
                  when /^\^(.+)/ then
                    "(^(#{Regexp.escape($1)}))"
                  when /(.+)\$$/ then
                    "((#{Regexp.escape($1)})$)"
                  else
                    "(" + Regexp.escape(token) + ")"
                end
              }.join("")
            else
              search = Regexp.quote(search)
            end
          end

          search
        end

        def mongo_handle_search(args = {})
          parameter = args[:parameter] || :search

          # Get the query
          search_query = args[:query] || params[parameter]
          if search_query.present? then
            expr = self.mongo_parse_search(search_query)

            # Build the query
            (args[:fields] || []).each do |field|
              @mongo_query = @mongo_query.any_of(field.to_sym => Regexp.new(expr, Regexp::EXTENDED | Regexp::MULTILINE | Regexp::IGNORECASE))
            end

            # Now add external fields
            # TODO: Can we enhance this?
            (args[:external] || []).each do |external|
              external_query = external[:class].not_deleted
              (external[:fields] || []).each do |field|
                external_query = external_query.any_of(field.to_sym => Regexp.new(expr, Regexp::EXTENDED | Regexp::MULTILINE | Regexp::IGNORECASE))
              end

              ids = external_query.only(:id).all.collect {|r| r.id }
              @mongo_query = @mongo_query.any_of(:cliente_id.in => ids) if ids.count > 0
            end    
          end

          @mongo_query
        end

        def mongo_handle_sorting(args = {})
          order = args[:order] || [:current, [:updated_at, :desc]]

          # Get current request sort order and then replace it into the sort fields
          current = self.mongo_get_sort_param(:default => args[:default])
          current_index = order.index(:current)
          order[current_index] = current if current_index

          # Assign data
          @mongo_sort_order = order    
        end

        def mongo_form_header(args = {})
          args[:record].try(:new_record?) ? "Create" : "Edit"
        end

        def mongo_form_submit_label(args = {})
          args[:record].try(:new_record?) ? "Create" : "Edit"
        end

        def mongo_get_page_param(args = {})
          page = [params[args[:parameter] || :page].to_integer, 1].max
          page = [page, args[:upperbound]].min if args[:upperbound].to_integer > 0
          page
        end

        def mongo_get_sort_param(args = {})
          if /^(?<what>[a-z0-9_]+)-(?<how>asc|desc)$/i.match(params[args[:param] || :sort_by]) && (args[:valids] || []).include?($~["what"]) then
            [$~["what"].to_sym, $~["how"].downcase.to_sym]
          else
            args[:default] || [:created_at, :desc]
          end
        end

        def mongo_delete(args = {})
          record = (args[:class] || @mongo_class).safe_find(args[:id])

          if record then
            args[:only_check] ? record.deletable? : record.delete(args[:definitive])
          else
            false
          end
        end
  
        def mongo_exists?(args)
          args[:class].not_deleted.where(args[:conditions]).count > 0
        end
  
        def mongo_is_available?(args = {})
          rv = self.setup_json_response(:validator)
          rv["success"] = true
          rv["valid"] = (self.mongo_exists?(args) == (args[:must_exists] || false))
          args[:internal] ? rv : self.custom_respond_with(rv.to_json)
        end
  
        def mongo_update_params_black_list(args = {})
          ["controller", "action", "id", "subdomain"] + (args[:additional] || [])
        end

        def mongo_update_params(args = {})
          blacklist = self.mongo_update_params_black_list(args)
          session["params-#{self.location_name}"] = (params.delete_if {|k,v| blacklist.include?(k) || params[k].is_a?(Tempfile) || params[k].blank?})
        end

        def mongo_end_write_action(args = {})
          redirect_to self.mongo_end_write_action_url(args)
        end

        def mongo_end_write_action_url(args = {})
          rp = {}

          if !args[:absolute] then
            rp = session["params-#{self.location_name(:index)}"] || {}
            rp[:action] = :index
          end

          if args[:additional].is_a?(Hash) then
            args[:additional].each { |k, v| rp[k] = v }
          end

          url_for(rp)
        end
      end
    end
  end
end