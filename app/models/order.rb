class Order < ActiveRecord::Base
  has_many :orderitems
  belongs_to :user

  def subtotal
    orderitems.map { |item| item.total_price }.sum
  end
end
