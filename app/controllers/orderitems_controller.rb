class OrderitemsController < ApplicationController

  def index
    redirect_to order_path(current_order.id)
  end

  def create
    @product = Product.find(params[:product_id])
    @orderitem = current_order.orderitems.create(product: @product, quantity: params[:quantity], user_id: @product.user_id)
    @orderitem.update(price: @orderitem.total_price)
    redirect_to edit_order_path(current_order.id)
  end


  def update
    @orderitem = Orderitem.find(params[:id])
    if @orderitem.update(orderitem_edit_params[:orderitem])
      @orderitem.update(price: @orderitem.total_price)
      redirect_to edit_order_path(current_order.id)
    else
      redirect_to root_path
    end
  end

  def shipped
    @orderitem = Orderitem.find(params[:id])
    @orderitem.shipped = true
    @orderitem.save
    redirect_to order_deets_path(id: current_user.id, order_id: @orderitem.order_id)

  end

  def destroy
    @orderitem = Orderitem.find(params[:id])
    @orderitem.destroy
    redirect_to edit_order_path(current_order.id)
  end

  private

  def orderitem_edit_params
    params.permit(orderitem: [:quantity])
  end


end
