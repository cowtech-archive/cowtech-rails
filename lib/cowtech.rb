# encoding: utf-8
#
# This file is part of the cowtech-rails gem. Copyright (C) 2011 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

dir = File.dirname(__FILE__) 

require 'cowtech-extensions'
require 'cowtech/extensions'
require 'cowtech/monkey_patches'
#require dir + '/../app/models/e_mail'
#require dir + '/../app/models/model_base'

module Cowtech
  class Engine < Rails::Engine
    rake_tasks do
      load "cowtech/tasks/app.rake"
      load "cowtech/tasks/log.rake"
      load "cowtech/tasks/server.rake"
      load "cowtech/tasks/sql.rake"
      load "cowtech/tasks/mongodb.rake"
    end
  end
end

Cowtech::Extensions.load!
