# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Cowtech
  module RubyOnRails
    module Helpers
      module BrowserHelper
        def browser_detect
          rv = {:engine => :unknown, :version => "0", :platform => :unknown, :agent => request.user_agent || request.env['HTTP_USER_AGENT'].downcase || ""}
          agent = rv[:agent].downcase

          # Identify engine
          if agent =~ /opera/ then
            rv[:engine] = :opera
          elsif agent =~ /webkit/ then
            rv[:engine] = (agent =~ /chrome|chromium/ ? :chrome : :safari)
          elsif agent =~ /msie/ || agent =~ /webtv/ then
            rv[:engine] = :msie
          elsif agent =~ /mozilla/ && agent !~ /compatible/ then
            rv[:engine] = :mozilla
          end

          # Identify version
          rv[:version] = $1 if agent =~ /.+(?:rv|it|ra|ie)[\/: ]([\d.]+)/
          rv[:version_number] = rv[:version].to_f

          # Identify platform
          if agent =~ /linux/
            rv[:platform] = :linux
          elsif agent =~ /macintosh|mac os x/ then
            rv[:platform] = :mac
          elsif agent =~ /windows|win32|win64/ then
            rv[:platform] = :windows
          end

          @browser = rv
        end

        def browser_classes
          self.browser_detect unless @browser
          rv = []

          # Add name and platform
          rv << @browser[:engine].to_s
          rv << "platform-#{@browser[:platform].to_s}"

          # Add versions
          version = "version-"
          i = -1
          @browser[:version].split(/\./).each do |v|
            i += 1
            version += "#{i > 0 ? "_" : ""}#{v}"
            rv << version
          end

          rv.join(" ")
        end
      end
    end
  end
end