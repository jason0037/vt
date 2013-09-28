require 'test_helper'
require 'pp'

class Store::CartControllerTest < ActionController::TestCase
	setup do
		@good = Ecstore::Good.find_by_goods_id(1679)
		cookies[:m_id] = request.session_options[:id]
		@m_id = cookies[:m_id]
	end

	test 'add a product to cart' do
		

		assert_difference('Ecstore::Cart.count') do
			xhr :post, :add, :product=>{:goods_id=>@good.goods_id,:specs=>[16,80],:quantity=>1}
		end
		assert_response :success
	end

	test 'add a product twice' do
		xhr :post, :add, :product=>{:goods_id=>@good.goods_id,:specs=>[16,80],:quantity=>1}

		assert_difference('assigns(:cart).quantity') do
			xhr :post, :add, :product=>{:goods_id=>@good.goods_id,:specs=>[16,80],:quantity=>1}
		end

		assert_response :success
	end
end