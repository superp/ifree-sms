# encoding: utf-8
require "curb"
require "base64"
require 'digest/md5'

module IfreeSms
  autoload :Smsing,    'ifree_sms/smsing'
  autoload :Manager,   'ifree_sms/manager'
  autoload :Config,    'ifree_sms/config'
  autoload :Callbacks, 'ifree_sms/callbacks'
  autoload :Response,  'ifree_sms/response'
  autoload :SMSDirectAPIMethods, 'ifree_sms/smsdirect_api'
  
  mattr_accessor :config
  @@config = Config.new
  
  class API
    # initialize with an access token
    def initialize(login = nil, pass = nil)
      @login = login || IfreeSms.config.login
      @pass = pass || IfreeSms.config.password
    end
    attr_reader :access_token

    def api(path, args = {}, verb = "get", options = {}, &error_checking_block)
      # Fetches the given path in the Graph API.
      args["login"] = @login
      args["pass"] = @pass
      
      # add a leading /
      path = "/#{path}" unless path =~ /^(\/|http|https|ftp)/

      # make the request via the provided service
      result = IfreeSms.make_request(path, args, verb, options)

      # Check for any 500 errors before parsing the body
      # since we're not guaranteed that the body is valid JSON
      # in the case of a server error
      raise APIError.new({"type"=>"HTTP #{result.status.to_s}", "message"=>"Response body: #{result.body}"}) if result.status >= 500
      
      body = result.body
      yield body if error_checking_block

      # if we want a component other than the body (e.g. redirect header for images), return that
      options[:http_component] ? result.send(options[:http_component]) : body
    end
  end
  
  class APIError < StandardError
    attr_accessor :sms_error_type
    def initialize(details = {})
      self.sms_error_type = details["type"]
      super("#{sms_error_type}: #{details["message"]}")
    end
  end
  
  # APIs
  
  class SMSDirectAPI < API
    include SMSDirectAPIMethods
  end
  
  # Class methods
  
  def self.setup(&block)
    yield config
  end
  
  def self.log(message)
    if IfreeSms.config.debug
      Rails.logger.info("[Ifree #{Time.now.strftime('%d.%m.%Y %H:%M')}] #{message}")
    end
  end
  
  def self.table_name_prefix
    'ifree_sms_'
  end
  
  def self.make_request(path, params, verb, options = {})
    query = Rack::Utils.build_query(params)
    url = [path, query].join('?')
    
    log("request: #{url}")
    
    http = Curl::Easy.new(url)
    http.perform
    
    log("response: #{http.body_str}")
    
    Response.new(http.response_code, http.body_str, http.headers)
  end
  
  def self.calc_digest(number, text, now)
    log("service_number: #{number}, sms_text: #{text}, now: #{now}, secret: #{config.secret_key}")
    
    Digest::MD5.hexdigest([number, text, config.secret_key, now].map(&:to_s).join)
  end
end

require 'ifree_sms/engine' if defined?(Rails)
