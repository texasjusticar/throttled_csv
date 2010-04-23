require 'test_helper'

# make methods public so we can test them
TestcsvController.class_eval do
  public :build_ar_options, :render_to_csv
end

class TestcsvControllerTest < ActionController::TestCase
  
  test "build_ar_options with :include" do
    @controller = TestcsvController.new
    options = {:db_table => "models", :include => [:association]}
    last_id = 30
    result = @controller.build_ar_options(last_id,options)
    expected_result = {:include => [:association], :conditions => ["models.id > ?",30], :order => "models.id asc", :limit => 100}
    assert_equal expected_result,result
  end
  
  test "build_ar_options basic" do
    @controller = TestcsvController.new
    options = {:db_table => "models"}
    last_id = 40
    result = @controller.build_ar_options(last_id,options)
    expected_result = {:conditions => ["models.id > ?",40], :order => "models.id asc", :limit => 100}
    assert_equal expected_result,result
  end
  
  test "csv response for test model" do
    setup do
      ActionController::Routing::Routes.draw do |map|
        map.connect "/testcsv",{:controller => "testcsv_controller", :action => "index"}
      end
    end
    get(:index)
    assert_response :success
    puts @response.inspect
   
  end
end