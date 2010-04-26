require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'action_controller'
require 'action_controller/test_process'
require 'test/unit'
require "#{File.dirname(__FILE__)}/../init"

class ActionController::TestCase
  # add a catch-all route for the tests only.
 ActionController::Routing::Routes.draw { |map| map.connect ':controller/:action/:id' }
end

class TestModel
  def self.all
    [
      {:id=>1,:name=>"first",:data=>"district 9 is better than avatar"},
      {:id=>2,:name=>"second",:data=>"magic happens here"},
      {:id=>3,:name=>"third",:data=>"thank you for reading my crazy"}
    ]
  end
  
  def self.find(*args)
    all
  end
end

class TestcsvController < ActionController::Base
  def index
    options = {
	    :db_table => "testmodels",
	    :label => "testmodel",
	    :scope => TestModel,
	    :fields => ["id","name","data"]
	  }
	  render_to_csv(options)
  end
end