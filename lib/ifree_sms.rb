# encoding: utf-8
require "curb"
require "base64"
require 'digest/md5'

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
    params[:serviceNumber] = config.service_number
    params[:smsText] = Base64.encode64(text)
    params[:now] = now
    params[:md5key] = calc_digest(config.service_number, params[:smsText], now)
    
    get(params)
  end
  
  def self.get(params)
    query = Rack::Utils.build_query(params)
    url = [config.url, query].join('?')
    
    log("request: #{url}")
    
    http = Curl::Easy.new(url)
    http.perform
    
    log("response: #{http.body_str}")
    
    http.body_str
  end
  
  def self.calc_digest(number, text, now)
    log("service_number: #{number}, sms_text: #{text}, now: #{now}, secret: #{config.secret_key}")
    
    Digest::MD5.hexdigest([number, text, config.secret_key, now].map(&:to_s).join)
  end
end

require 'ifree_sms/engine' if defined?(Rails)
