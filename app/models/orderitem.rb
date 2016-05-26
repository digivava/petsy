class Orderitem < ActiveRecord::Base
  belongs_to :product
  belongs_to :order
  belongs_to :user
  validates :quantity, presence: true, numericality: {only_integer: true, greater_than: 0}

  def total_price
    self.product.price * self.quantity
  end


end
