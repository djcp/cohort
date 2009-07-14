require 'test_helper'

class ContactCartsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contact_carts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contact_cart" do
    assert_difference('ContactCart.count') do
      post :create, :contact_cart => { }
    end

    assert_redirected_to contact_cart_path(assigns(:contact_cart))
  end

  test "should show contact_cart" do
    get :show, :id => contact_carts(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => contact_carts(:one).to_param
    assert_response :success
  end

  test "should update contact_cart" do
    put :update, :id => contact_carts(:one).to_param, :contact_cart => { }
    assert_redirected_to contact_cart_path(assigns(:contact_cart))
  end

  test "should destroy contact_cart" do
    assert_difference('ContactCart.count', -1) do
      delete :destroy, :id => contact_carts(:one).to_param
    end

    assert_redirected_to contact_carts_path
  end
end
