require 'test_helper'

class Store::GoodsControllerTest < ActionController::TestCase
  test "should get index" do
    get :cheuksgroup
    assert_response :redirect
  end

  # test "should get show" do
  #   get :show
  #   assert_response :success
  # end

  test "should get more goods" do
  	get 'more'
  	
  	assert_not_nil assigns(:tags)
  	assert assigns(:tags).count <= 9
  	asert_template 'more'
  	assert_response :success
  	assert_select 'ul.issues' do
  		assert_select 'li.issue', 9
  	end
  end


end
