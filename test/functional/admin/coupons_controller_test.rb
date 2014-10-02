require 'test_helper'

class Admin::CouponsControllerTest < ActionController::TestCase
  test "should get index" do
    get :cheuksgroup
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

end
