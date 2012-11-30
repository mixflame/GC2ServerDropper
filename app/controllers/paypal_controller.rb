class PaypalController < ApplicationController

  protect_from_forgery :except => :paypal_ipn

  # This will be called when soemone first subscribes
  def sign_up_user(custom, plan_id)
    logger.info("sign_up_user (#{custom}) #{plan_id}")
  end

  # This will be called if someone cancels a payment
  def cancel_subscription(custom, plan_id)
    logger.info("cacnel_subscription (#{custom}) #{plan_id}")
  end

  # This will be called if a subscription expires
  def subscription_expired(custom, plan_id)
    logger.info("subscription_expired (#{custom}) #{plan_id}")
  end

  # Called if a subscription fails
  def subscription_failed(custom, plan_id)
    logger.info("subscription_failed (#{custom}) #{plan_id}")
  end

  # Called each time paypal collects a payment
  def subscription_payment(custom, plan_id)
    logger.info("recurrent_payment_received (#{custom}) #{plan_id}")
  end

  # process the PayPal IPN POST
  def paypal_ipn

    # use the POSTed information to create a call back URL to PayPal
    query = 'cmd=_notify-validate'
    request.params.each_pair {|key, value| query = query + '&' + key + '=' +
    value if key != 'register/pay_pal_ipn.html/pay_pal_ipn' }

    paypal_url = 'www.paypal.com'
    if ENV['RAILS_ENV'] == 'development'
      logger.info 'using sandbox'
      paypal_url = 'www.sandbox.paypal.com'
    end

    # Verify all this with paypal
    http = Net::HTTP.start(paypal_url, 80)
    response = http.post('/cgi-bin/webscr', query)
    case response
    when Net::HTTPSuccess     then response
    when Net::HTTPRedirection then logger.info "redirect to #{response['location']}" #response = http.post(response['location'], query)
    else
      response.error!
    end
    http.finish

    item_name = params[:item_name]
    item_number = params[:item_number]
    payment_status = params[:payment_status]
    txn_type = params[:txn_type]
    custom = params[:custom]

    logger.info "payment status: #{payment_status}"
    logger.info "txn_type #{txn_type}"
    logger.info "response #{response.inspect}"

    # Paypal confirms so lets process.
    if response && response.body.chomp == 'VERIFIED'

      if txn_type == 'subscr_signup'
        sign_up_user(custom, item_number)
      elsif txn_type == 'subscr_cancel'
        cancel_subscription(custom, item_number)
      elsif txn_type == 'subscr_eot'
        subscription_expired(custom, item_number)
      elsif txn_type == 'subscr_failed'
        subscription_failed(custom, item_number)
      elsif txn_type == 'subscr_payment' && payment_status == 'Completed'
        subscription_payment(custom, item_number)
      end

      render :text => 'OK'

    else
      render :text => 'ERROR'
    end
  end
end