# Include hook code here
require "throttled_csv"

ActionController::Base.class_eval do
  include ThrottledCsv
end