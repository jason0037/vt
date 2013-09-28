require 'test_helper'

class Events::ApplicantsControllerTest < ActionController::TestCase
  
  test "should create applicant" do
    assert_difference('Ecstore::Applicant.count') do
    	xhr :post, :create, :applicant=>
    end

    assert_response :success
  end


end
