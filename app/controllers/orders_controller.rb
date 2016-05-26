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
  end

  def confirmation
    @order = current_order
    @orderitems = @order.orderitems
    session.delete :order_id
    order = Order.create
    order.update(status: "Pending")
    session[:order_id] = order.id

    ## connection with shipping-service api
    ## BROKEN: not recognizing any of the existing users for some reason... why?! just using a central warehouse location instead for now
    # @order.orderitems.each do |item|
    #   merchant = User.find_by(id: item.product.user_id)
    #   request = {
    #     origin:
    #       { street_address: merchant.street_address, city: merchant.city, state: merchant.state, zip: merchant.state },
    #     destination:
    #       { street_address: @order.street_address, city: @order.city, state: @order.state, zip: @order.billing_zip },
    #     product:
    #       { height: item.product.height, width: item.product.width, weight: item.product.weight }
    #     }
    # end

    @order.orderitems.each do |item|
      request = {
        origin:
          # default address of Ada (treating it like a central warehouse)
          { street_address: "1215 4th Ave", city: "Seattle", state: "WA", zip: "98161" },
        destination:
          { street_address: @order.street_address, city: @order.city, state: @order.state, zip: @order.billing_zip },
        product:
          { height: item.product.height, width: item.product.width, weight: item.product.weight }
        }

      @response = HTTParty.post("http://localhost:3001/quote", body: request.to_json)

    end

    # connection with shipping-service API
    # @merchant = @order.user
    # order_items = @order.orderitems.map { |item| { height: item.product.height, width: item.product.width, weight: item.product.weight } }
    #
    # request = { origin: { street_address: @user.street_address, city: @user.city, state: @user.state, zip: @user.zip }, destination: { street_address: @order.street_address, city: @order.city, state: @order.state, zip: @order.billing_zip }, products: order_items }.to_json
    #
    # response = HTTParty.get("https://agile-shore-50946.herokuapp.com/quote", body: request)

    # binding.pry

    # render the shipping costs from the response
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
