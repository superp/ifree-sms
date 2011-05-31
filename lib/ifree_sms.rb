# encoding: utf-8
require "curb"
require "base64"

module IfreeSms
  autoload :Smsing,    'ifree_sms/smsing'
  autoload :Manager,   'ifree_sms/manager'
  autoload :Config,    'ifree_sms/config'
  autoload :Callbacks, 'ifree_sms/callbacks'
  
  mattr_accessor :config
  @@config = Config.new
  
  def self.setup(&block)
    yield config
  end
  
  def self.log(message)
    if IfreeSms.config.debug
      Rails.logger.info("[IfreeSms] #{message}")
    end
  end
  
  def self.table_name_prefix
    'ifree_sms_'
  end
 
  # Send sms message
  # Sample request:
  # http://srv1.com.ua/mcdonalds/second.php?smsId=noID&phone=380971606179&serviceNumber=3533&smsText=test-message&md5key=f920c72547012ece62861938b7731415&now=20110527160613
  #
  def self.send_sms(phone, text, sms_id='noID')
    now = Time.now.utc.strftime("%Y%m%d%H%M%S")
    
    params = {}
    params[:smsId] = sms_id
    params[:phone] = phone
    params[:serviceNumber] = IfreeSms.config.service_number
    params[:smsText] = Base64.encode64(text)
    params[:now] = now
    params[:md5key] = calc_digest(IfreeSms.config.service_number, params[:smsText], now)
    
    
    c = Curl::Easy.new([IfreeSms.config.url, Rack::Utils.build_query(params)].join('?'))
    c.perform
    c.body_str
  end
end

require 'ifree_sms/engine' if defined?(Rails)
