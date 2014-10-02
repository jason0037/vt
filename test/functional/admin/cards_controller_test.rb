require 'test_helper'

class Admin::CardsControllerTest < ActionController::TestCase
  setup do
    @admin_card = admin_cards(:one)
  end

  test "should get index" do
    get :cheuksgroup
    assert_response :success
    assert_not_nil assigns(:admin_cards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_card" do
    assert_difference('Admin::Card.count') do
      post :create, admin_card: { buyer_tel: @admin_card.buyer_tel, card_type: @admin_card.card_type, no: @admin_card.no, sale_status: @admin_card.sale_status, status: @admin_card.status, use_status: @admin_card.use_status, user_tel: @admin_card.user_tel, value: @admin_card.value }
    end

    assert_redirected_to admin_card_path(assigns(:admin_card))
  end

  test "should show admin_card" do
    get :show, id: @admin_card
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_card
    assert_response :success
  end

  test "should update admin_card" do
    put :update, id: @admin_card, admin_card: { buyer_tel: @admin_card.buyer_tel, card_type: @admin_card.card_type, no: @admin_card.no, sale_status: @admin_card.sale_status, status: @admin_card.status, use_status: @admin_card.use_status, user_tel: @admin_card.user_tel, value: @admin_card.value }
    assert_redirected_to admin_card_path(assigns(:admin_card))
  end

  test "should destroy admin_card" do
    assert_difference('Admin::Card.count', -1) do
      delete :destroy, id: @admin_card
    end

    assert_redirected_to admin_cards_path
  end
end
