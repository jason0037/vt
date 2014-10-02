require 'test_helper'

class ReviewControllerTest < ActionController::TestCase
  test "should get index" do
    get :cheuksgroup
    assert_response :success
  end

end
