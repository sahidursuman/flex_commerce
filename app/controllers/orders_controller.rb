class OrdersController < UsersController
  # Filters
  before_action :request_signin, only: [:create]
  before_action :authenticate_user, except: [:create]
  before_action :set_order, except: [:create, :index]

  def create
    order = OrderService.new(cart_id: params[:cart_id]).create
    if order
      redirect_to select_shipping_order_path(order)
    else
      flash[:danger] = 'Unable to create order.'
      redirect_to cart_path
    end
  end

  def select_shipping
  end

  def set_shipping
    raise
  end

  private

    def set_order
      @order = Order.find(params[:id])
    end

    def request_signin
      unless helpers.signed_in?
        helpers.store_return_url
        redirect_to signin_path
      end
    end

end