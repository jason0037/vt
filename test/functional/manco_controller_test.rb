require 'test_helper'

class MancoControllerTest < ActionController::TestCase
  test "should get index" do
    get :cheuksgroup
    assert_response :success
  end

end
