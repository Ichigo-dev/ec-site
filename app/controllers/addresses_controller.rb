class AddressesController < ApplicationController
  def update
    @id = params[:address][:id]
    @param = address_param 
    Address.find(@id).update!(user_id: nil)
    @address = Address.new(@param)
    unless @address.save
      render :errors
    end
  end

  def destroy
  end

  private

  def address_param
    params.require(:address).permit(:postal_code, :prefecture, :city, :address1, :address2, :family_name, :given_name, :email, :user_id)
  end

  def card_param
    params.require(:card).permit(:name, :card_num, :expiration_date, :security_code, :user_id)
  end

end