$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'active_record/acts/publish'
ActiveRecord::Base.class_eval { include ActiveRecord::Acts::Publish }
