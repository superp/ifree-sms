# encoding: utf-8
module IfreeSms
  module Callbacks
    # Hook to _run_callbacks asserting for conditions.
    def _run_callbacks(kind, *args) #:nodoc:
      options = args.last # Last callback arg MUST be a Hash

      send("_#{kind}").each do |callback, conditions|
        invalid = conditions.find do |key, value|
          value.is_a?(Array) ? !value.include?(options[key]) : (value != options[key])
        end

        callback.call(*args) unless invalid
      end
    end
    
    # A callback that runs after message created
    # Example:
    #   IfreeSms::Manager.incoming_message do |env, opts|
    #   end
    #
    def incoming_message(options = {}, method = :push, &block)
      raise BlockNotGiven unless block_given?
      _incoming_message.send(method, [block, options])
    end
    
    # Provides access to the callback array for incoming_message
    # :api: private
    def _incoming_message
      @_incoming_message ||= []
    end
  end
end
