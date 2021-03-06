class Cart < ApplicationRecord
  has_many :order_details
  belongs_to :user, optional: true
  has_one :receipt

  def empty?
    order_count = self.order_details.count
    order_count.zero?
  end

  def price_add_comma
    price_comma = self.price_sum_tax.to_s(:delimited)
  end

  def price_all_add_comma
    price_comma = self.price_tax_add_fee.to_s(:delimited)
  end

  def price_sum
    order_details = self.order_details.preload(:product)
    price_sum = order_details.to_a.sum { |o| o.product.price * o.product_count }
  end

  def price_sum_tax
    price_sum = self.price_sum

    price_sum *= 1.1 # tax
    price_sum.floor
  end

  def price_add_fee
    price_add_fee = self.price_sum + 550
  end

  def price_tax_add_fee
    price_add_fee = self.price_sum_tax + 550
  end
  
  def pay_with_card!(customer = nil, payjp_token = nil, save_card = false)
    options = {
      amount: self.price_tax_add_fee,
      currency: "jpy"
    }
    if save_card
      customer.cards.create(
        card: payjp_token,
        default: true,
      )
      options[:customer] = customer.id
    elsif payjp_token
      options[:card] = payjp_token
    else
      options[:customer] = customer.id
    end
    Payjp::Charge.create(options)
  end
end
