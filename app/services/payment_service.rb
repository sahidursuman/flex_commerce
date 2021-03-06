class PaymentService
  include ApplicationHelper
  include AlipayHelper
  attr_accessor :order, :payment, :amount, :user, :processor, :processor_client

  def initialize(order_id: nil, payment_id: nil, processor: nil, amount: nil,
                 variety: nil, user_id: nil, withdrawable: true)
    @payment = Payment.find_by(id: payment_id)
    @order = Order.find_by(id: order_id) || @payment.try(:order)
    @processor = processor || @payment.try(:processor)
    @amount = amount || @order.try(:amount_unpaid) || @payment.try(:amount)
    @user = User.find_by(id: user_id) || @order.try(:user)
    @variety = variety || 'charge'
    @withdrawable = withdrawable
  end

  def create
    case @variety
    when 'charge' then create_charge
    when 'reward' then create_reward
    end
  end

  def charge
    case @payment.processor
    when 'wallet' then charge_wallet
    when 'alipay' then charge_alipay
    end
  end

  def reward
    begin
      Payment.transaction do
        deposit_reward
        create_transaction
        true
      end
    rescue Exception
      false
    end
  end

  def create_charge
    begin
      Payment.transaction do
        build_charge
        validate_order_status
        validate_amount_with_order
        validate_customer_fund if @payment.processor == 'wallet'
        @order.payment_pending!
        @payment
      end
    rescue Exception
      @payment = nil
      false
    end
  end

  def create_reward
    begin
      Payment.transaction do
        build_reward
        validate_order_status
        true
      end
    rescue Exception
      @payment = nil
      false
    end
  end

  def build_charge
    @payment = Payment.create!(order: @order, processor: @processor,
                               variety: 'charge', amount: @amount)
    build_processor
  end

  def build_reward
    @payment = Payment.create!(order: @order, amount: @amount,
                               processor: 'wallet', variety: 'reward')
  end

  def create_processor_client
    Alipay::Client.new(url: ENV['ALIPAY_GATEWAY'],
                       app_id: ENV['ALIPAY_APP_ID'],
                       app_private_key: ENV['ALIPAY_APP_PRIVATE_KEY'],
                       alipay_public_key: ENV['ALIPAY_PUBLIC_KEY'])
  end

  def create_processor_request
    biz_content = Hash.new.tap do |h|
      h[:out_trade_no] = @payment.id
      h[:product_code] = 'FAST_INSTANT_TRADE_PAY'
      h[:total_amount] = @payment.order.amount_unpaid.to_f
      h[:subject] = "[#{app_title}] Payment for order: #{@payment.order.id}"
    end
    @payment.update(processor_request: biz_content)
  end

  def build_processor
    return unless @payment.alipay?
    @processor_client = create_processor_client
    create_processor_request
  end

  def mark_success
    @payment.processor_confirmed!
    create_transaction
  end

  def mark_failure
    @payment.insufficient_fund!
  end

  def process_result
    if @order.reload.amount_unpaid == 0
      @order.payment_success!
      confirm_inventories
      distribute_rewards
    elsif @payment.status_before_type_cast >= 20
      @order.partial_payment!
    else
      @order.payment_fail! unless @order.partial_payment?
    end
  end

  def charge_wallet
    begin
      Payment.transaction do
        validate_customer_fund
        @user.wallet.debit(@amount)
        @payment.update(amount: @amount)
        mark_success
        process_result
        true
      end
    rescue Exception
      mark_failure
      process_result
      false
    end
  end

  def charge_alipay
    @processor_client.page_execute_url(
      method: 'alipay.trade.page.pay',
      return_url: ENV['API_RETURN_ROOT'] + "/payments/#{@payment.id}/alipay_return",
      notify_url: ENV['API_RETURN_ROOT'] + "/payments/#{@payment.id}/alipay_notify",
      biz_content: @payment.processor_request.to_json,
    )
  end

  def alipay_confirm
    begin
      Payment.transaction do
        validate_processor_response
        confirm_payment_and_order
        create_transaction
        confirm_inventories
        distribute_rewards
        true
      end
    rescue Exception
      false
    end
  end

  def deposit_reward
    if @withdrawable
      @user.wallet.credit(@amount)
    else
      @user.wallet.conditional_credit(@amount)
    end
    @payment.confirmed!
  end

  private

    def validate_order_status
      if @variety == 'charge'
        return true if @order.status_before_type_cast.between?(20, 59)
      elsif @variety == 'reward'
        return true if @order.status_before_type_cast >= 60
      end
      raise(StandardError, 'Invalid order status.')
    end

    def validate_amount_with_order
      return true if @payment.amount <= @order.total
      raise(StandardError, 'Payment amount cannot exceed order total.')
    end

    def validate_customer_fund
      return true if @user.wallet.sufficient_fund?(@payment.amount)
      raise(StandardError, 'Insufficient fund')
    end

    def validate_processor_response
      rsp = @payment.processor_response_return ||
            @payment.processor_response_notify

      if rsp['out_trade_no'] != @payment.id
        raise(StandardError, 'Invalid out_trade_no')
      elsif rsp['total_amount'] != @payment.amount.to_s
        raise(StandardError, 'Invalid total_amount')
      else
        true
      end
    end

    def confirm_payment_and_order
      if @payment.processor_response_return.present? &&
            @payment.processor_response_notify.present?
        @payment.confirmed!
      elsif @payment.processor_response_return.present?
        @payment.client_side_confirmed!
      elsif @payment.processor_response_notify.present?
        @payment.processor_confirmed!
      end
      @payment.order.payment_success!
    end

    def confirm_inventories
      if @order.reload.payment_success?
        @order.inventories.each do |inv|
          inv.update(purchased_at: DateTime.now, status: 4)
        end
      end
    end

    def create_transaction
      unless @payment.transaction_log
        processable = @payment.wallet? ? @user.wallet : nil
        Transaction.create(
         amount: @amount,
         originable: @payment,
         transactable: @order,
         processable: processable)
      end
    end

    def distribute_rewards
      reward_service = RewardService.new(order_id: @order.id)
      reward_service.distribute
    end
end
