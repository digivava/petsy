require'timeout'
TIMEOUT_SECONDS = 20

class OrdersController < ApplicationController
  before_action :require_login, only: [:show_seller_orders]

  def show
    @orders = Order.find(current_order.id).orderitems
  end

  def show_seller_orders
  	@user = User.find(current_user.id)
    @user_orders_hash = Orderitem.where(user: current_user).group_by(&:order_id)
    @revenue = @user.revenue
    @completed_revenue = @user.revenue_by_status("Completed")
    @pending_revenue = @user.revenue_by_status("Pending")
    @completed_count = @user.order_by_status("Completed")
    @pending_count = @user.order_by_status("Pending")
  end

  def order_deets
    @user_orders_hash = Orderitem.where(user: current_user).group_by(&:order_id)
    @order = Order.find(params[:order_id])
  end


  def edit
    @order  = Order.find(params[:id])
    @orderitems = Order.find(current_order.id).orderitems
  end

  def update
    @order = current_order
    @orderitems = @order.orderitems
    continue = remove_items_from_stock(@orderitems)
    unless continue == false
      @order.update(order_update_params[:order])
    end
    if @order.status == "Completed"
      redirect_to order_confirmation_path(@order.id)
    else
      flash[:notice] = "Sorry! An item you wanted is out of stock. Check to see if you have duplicate items in your cart."
      redirect_to edit_order_path(current_order.id)
    end
  end


  def checkout
    @user = User.find(current_user.id)
    # original code
    @order = current_order
    if @order.orderitems.count == 0
      redirect_to edit_order_path(current_order.id), alert: "Please add items to your cart!"
    end

    products = @order.orderitems.map do |item|
      {
        height: item.product.height, width: item.product.width, weight: item.product.weight
      }
    end
    request = {
      origin:
        # default address of Ada (treating it like a central warehouse)
        { street_address: "1215 4th Ave", city: "Seattle", state: "WA", zip: "98161" },
      destination:
        { street_address: @user.street_address, city: @user.city, state: @user.state, zip: @user.zip },
      products: products
    }
      begin
      Timeout::timeout(TIMEOUT_SECONDS) do
        @response = HTTParty.post("https://evening-depths-89076.herokuapp.com/quote", body: { request: request.to_json })
        end
      rescue => error
      redirect_to edit_order_path(current_order.id)
      flash[:error] = "Sorry session timed out. Try again."
      end

  end

  def confirmation
    @order = current_order
    @orderitems = @order.orderitems
    if @order.price
      session.delete :order_id
      order = Order.create
      order.update(status: "Pending")
      session[:order_id] = order.id
      render :confirmation
    else
      flash[:error] = "Your request was incomplete. Make sure to first select a shipping method, then click Update Shipping before proceeding to checkout."
      redirect_to order_checkout_path
    end
  end

  def shipping_price
    order = Order.find(params[:id])
    @shipping_price = (params[:service].to_f / 100 )
    order.price = order.subtotal + @shipping_price
    order.save!
    checkout
    render :checkout
  end


  private



  def remove_items_from_stock(items)
    items.each do |item|
      product = item.product
      quantity_being_bought = item.quantity
      available_quantity = product.quantity
      new_quantity = available_quantity - quantity_being_bought
      if new_quantity >= 0
        product.update(quantity: new_quantity)
      else
        return false
      end
    end
  end

  def orderitem_edit_params
    params.permit(orderitem: [:quantity])
  end

  def order_update_params
    params[:order][:credit_card_number] = params[:order][:credit_card_number][-4..-1]
    params.permit(order: [:name_on_credit_card, :user_id, :city, :state, :billing_zip,
      :email, :status, :street_address, :credit_card_cvv, :credit_card_number, :credit_card_exp_date])
  end

end
