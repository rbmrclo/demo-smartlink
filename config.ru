require 'digest'
require 'active_support'
require 'active_support/core_ext'
require 'pry'
require 'uri'
require 'cgi'
require 'openssl'
require 'sinatra'

class App < Sinatra::Base

  get '/' do
    @merchant        = "SMLTEST"
    @version         = "2.0"
    @command         = "pay"
    @merchant_ref    = "Test1-#{Time.now.to_i}"
    @access_code     = ENV.fetch("ACCESS_CODE", "ECAFAB")
    @amount          = 10_000_000.to_s
    @currency        = "VND"
    @order_info      = "test order"
    @locale          = "vn"
    @ip_address      = "192.168.0.1"
    @return_url      = "http://localhost:9393/return_url"
    @back_url        = "http://localhost:9393/back_url"

    erb :form
  end

  post '/order' do
    GATEWAY_URL   = "http://payment.smartlink.com.vn/gateway/vpcpay.do" # sandbox url
    SECURE_SECRET = ENV.fetch("SECURE_SECRET", "198BE3F2E8C75A53F38C1C4A5B6DBA27")

    _query = {
      'vpc_Merchant'       => params[:merchant],
      'vpc_Version'        => params[:version],
      'vpc_Command'        => params[:command],
      'vpc_AccessCode'     => params[:access_code],
      'vpc_Amount'         => params[:amount],
      'vpc_Currency'       => params[:currency],
      'vpc_Locale'         => params[:locale],
      'vpc_MerchTxnRef'    => params[:merchant_ref],
      'vpc_OrderInfo'      => params[:order_info],
      'vpc_ReturnURL'      => params[:return_url],
      'vpc_BackURL'        => params[:back_url],
      'vpc_TicketNo'       => params[:ip_address]
    }

    query = _query.sort.to_h

    hash_data    = "#{SECURE_SECRET}#{query.values.join}"
    secure_hash  = Digest::MD5.hexdigest(hash_data).upcase
    request_data = query.to_query
    vpc_url      = [GATEWAY_URL, "?", request_data, "&vpc_SecureHash=", secure_hash].join

    redirect vpc_url
  end

  get '/return_url' do
    @amount         = params["vpc_Amount"]
    @currency       = params["vpc_CurrencyCode"]
    @command        = params["vpc_Command"]
    @merchant_ref   = params["vpc_MerchTxnRef"]
    @transaction_no = params["vpc_TransactionNo"]
    @order_info     = params["vpc_OrderInfo"]
    @locale         = params["vpc_Locale"]
    @secure_hash    = params["vpc_SecureHash"]

    erb :summary
  end

  get '/back_url' do
    @amount         = params["vpc_Amount"]
    @currency       = params["vpc_CurrencyCode"]
    @command        = params["vpc_Command"]
    @merchant_ref   = params["vpc_MerchTxnRef"]
    @transaction_no = params["vpc_TransactionNo"]
    @order_info     = params["vpc_OrderInfo"]
    @locale         = params["vpc_Locale"]
    @secure_hash    = params["vpc_SecureHash"]

    erb :summary
  end

end

run App
