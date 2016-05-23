class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :current_order

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def current_order
    order ||= Order.find_by(id: session[:order_id])

    if order.nil?
       order = Order.create(status: "Pending")
       session[:order_id] = order.id
     end

    order
  end



  def require_login
    if current_user.nil?
      flash[:error] = "You must be logged in to view this section"
      redirect_to new_session_path
    end
  end

end
