# encoding: utf-8
module IfreeSms
  class Manager
    extend IfreeSms::Callbacks
    
    attr_accessor :config
    
    # Initialize the middleware. If a block is given, a IfreeSms::Config is yielded so you can properly
    # configure the IfreeSms::Manager.
    def initialize(app, options={})
      options.symbolize_keys!

      @app, @config = app, IfreeSms::Config.new(options)
      yield @config if block_given?
      self
    end
    
    def call(env) # :nodoc:
      if smsing_path?(env['PATH_INFO']) && env["REQUEST_METHOD"] == "GET"
        create(env)
      else
        @app.call(env)
      end
    end
    
    # :api: private
    def _run_callbacks(*args) #:nodoc:
      self.class._run_callbacks(*args)
    end
    
    protected
      
      def create(env, body = '', status = 500)
        request = Rack::Request.new(env)
        message = IfreeSms::Message.new(:request => request)
        
        _run_callbacks(:before_message, env, message)
        
        body, status = message.call
        
        _run_callbacks(:after_message, env, message)
        
        [status, {'Content-Type' => 'application/xml', 'Content-Length' => body.size.to_s}, body]
      end
      
      def smsing_path?(request_path)
        return false if @config.routes.nil?

        @config.routes.keys.any? do |route|
          route == request_path
        end
      end
  end
end
