class CheckoutsController < ApplicationController
  include Pagy::Backend
  before_action :is_cart, except: [:completed]
  before_action :has_address_session, only: [:card_form_show, :confirm]
  before_action :has_card_session, only: [:confirm]
  before_action :set_order_details, only: [:address_form_show, :address_set_session, :card_form_show, :confirm]
  before_action :set_payjp_key, only: [:card_form_show, :confirm, :issue_receipt, :completed]
  before_action :summarize_order_details, only: [:issue_receipt]

  def address_form_show
    @address = Address.new(session[:address]) || Address.new()

    if current_user
      @addresses = current_user.addresses
      render :address_form_user
    else
      render :address_form
    end
  end

  def address_set_session
    session[:is_save_address] = params[:page][:is_save] if current_user
    session[:address_radio] = params[:page][:category]

    if session[:address_radio] == 'new' #配送先入力時
      @address = Address.new(address_param)

      if @address.valid?
        session[:address] = address_param
        # 配送先を保存する際にuser_idをパラメータに含める
        session[:address][:user_id] = current_user.id if session[:is_save_address]
        redirect_to :checkouts_card
      else
        if current_user
          @addresses = current_user.addresses
          render :address_form_user
        else
          render :address_form
        end
      end
    else #配送先選択（ログイン時）
      session[:address] = Address.find(params[:page][:category])
      redirect_to :checkouts_card
    end
  end

  def card_form_show
    if current_user
      customer = current_user.get_payjp_customer
      @customer_card = customer.cards.retrieve(customer.default_card) if customer.default_card
      render :card_form_user
    else
      render :card_form
    end
  end

  def card_set_session
    session[:is_save_card] = params[:page][:is_save] if current_user
    session[:card_radio] = params[:page][:category]

    if params[:page][:category] == 'new'
      session[:payjp_token] = params[:payjp_token]
    end
    redirect_to :checkouts_confirm
  end

  def confirm
    if session[:card_radio] == 'default'
      customer = current_user.get_payjp_customer
      @customer_card = customer.cards.retrieve(customer.default_card)
    else
      @customer_card = Payjp::Token.retrieve(session[:payjp_token]).card
    end
  end

  def issue_receipt
    # Receiptに紐づける配送先
    address = if session[:address_radio] == 'new'
      Address.create!(session[:address])
    else
      Address.find(session[:address_radio])
    end

    charge = current_cart.pay_with_card!(current_user&.get_payjp_customer, session[:payjp_token], session[:is_save_card])
       
    if current_user
      Receipt.create!(cart_id: current_cart.id, address_id: address.id, total_price: current_cart.price_add_fee, total_price_tax: current_cart.price_tax_add_fee, charge_id: charge.id, user_id: current_user.id)
    else
      receipt = Receipt.create!(cart_id: current_cart.id, address_id: address.id, total_price: current_cart.price_add_fee, total_price_tax: current_cart.price_tax_add_fee, charge_id: charge.id)
      session[:receipt] = [] unless session[:receipt] 
      session[:receipt] << receipt.id # 匿名時の注文履歴
    end

    session_clear
    cart = Cart.create!(user_id: current_user.id) if current_user # ユーザーのカート初期化
    redirect_to :checkouts_completion
  end

  def completed # 注文履歴（名前が適切でない）
    if current_user
      @pagy, @receipts = pagy(current_user.receipts.order(id: 'DESC'), items: 6)
    elsif session[:receipt]
      @pagy, @receipts = pagy(Receipt.where(id: session[:receipt]).order(id: 'DESC'), items: 6)
    end
    render :completion
  end

  private

  def is_cart
    if current_cart.empty?
      redirect_to cart_path
    end
  end

  def has_address_session
    unless session[:address]
      redirect_to carts_path
    end
  end

  def has_card_session
    unless session[:payjp_token] || session[:card_radio] == 'default'
      redirect_to cart_path
    end
  end

  def set_order_details
    @order_details = current_cart.order_details
  end

  def set_payjp_key
    Payjp.api_key = ENV['PAYJP_API_KEY']
  end

  def summarize_order_details
    order_details = current_cart.order_details
    order_details.update(cart_id: nil)
    order_details.each do |order|
      # ここで処理が重くなってる気がするからどうにかしたい
      order_detail = current_cart.order_details.find_by(product_id: order.product_id)
      if order_detail.nil?
        order.update(cart_id: current_cart.id)
      else
        order_detail.product_count += order.product_count
        order_detail.save
      end
    end
  end

  def address_param
    params.require(:address).permit(:postal_code, :prefecture, :city, :address1, :address2, :family_name, :given_name, :email)
  end

  def session_clear
    session.delete(:cart_id)
    session.delete(:address)
    session.delete(:card)
    session.delete(:payjp_token)
    session.delete(:address_radio)
    session.delete(:card_radio)
    session.delete(:is_save_card)
    session.delete(:is_save_address)
  end

end
