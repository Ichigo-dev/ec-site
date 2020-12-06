class CheckoutsController < ApplicationController
  layout 'checkouts'
  before_action :is_cart

  def address_form_show
    @address = Address.new
    @cart = Cart.find(session[:cart_id])
    render :address_form
  end

  def address_set_session
    session[:address] = address_param
    redirect_to :checkouts_card
  end

  def card_form_show
    @address = Address.new
    @cart = Cart.find(session[:cart_id])
    render :card_form
  end

  def card_set_session
  end

  def confirm
  end

  def issue_receipt
  end

  def completion_show
  end

  private

  def is_cart
    order_count = Cart.find(session[:cart_id]).order_details.count
    if order_count == 0
      redirect_to carts_path
    end
  end

  def address_param
    params.require(:address).permit(:postal_code, :prefecture, :city, :address1, :address2, :family_name, :given_name, :email)
  end
end
