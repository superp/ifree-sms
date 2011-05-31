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
      if smsing_path?(env['PATH_INFO'])
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
        
        unless message.test?          
          _run_callbacks(:incoming_message, env, message) if message.save
          
          body, status = message.response_to_ifree
        else
          body, status = [message.test_to_ifree, 200]
        end
        
        [status, {'Content-Type' => 'application/xml', 'Content-Length' => body.size.to_s}, body]
      end
      
      def smsing_path?(request_path)
        return false if @config.routes.nil?

        @config.routes == request_path
      end
  end
end
