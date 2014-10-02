require 'test_helper'

class Admin::ResourcesControllerTest < ActionController::TestCase
  setup do
    @admin_resource = admin_resources(:one)
  end

  test "should get index" do
    get :cheuksgroup
    assert_response :success
    assert_not_nil assigns(:admin_resources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_resource" do
    assert_difference('Admin::Resource.count') do
      post :create, admin_resource: { action: @admin_resource.action, action_desc: @admin_resource.action_desc, controller: @admin_resource.controller, controller_desc: @admin_resource.controller_desc }
    end

    assert_redirected_to admin_resource_path(assigns(:admin_resource))
  end

  test "should show admin_resource" do
    get :show, id: @admin_resource
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_resource
    assert_response :success
  end

  test "should update admin_resource" do
    put :update, id: @admin_resource, admin_resource: { action: @admin_resource.action, action_desc: @admin_resource.action_desc, controller: @admin_resource.controller, controller_desc: @admin_resource.controller_desc }
    assert_redirected_to admin_resource_path(assigns(:admin_resource))
  end

  test "should destroy admin_resource" do
    assert_difference('Admin::Resource.count', -1) do
      delete :destroy, id: @admin_resource
    end

    assert_redirected_to admin_resources_path
  end
end
