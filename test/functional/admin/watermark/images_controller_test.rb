require 'test_helper'

class Admin::Watermark::ImagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :cheuksgroup
    assert_response :success
  end

  test "should get rollback" do
    get :rollback
    assert_response :success
  end

  test "should get mark" do
    get :mark
    assert_response :success
  end

end
