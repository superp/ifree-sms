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
    
    # A callback that runs before create message
    # Example:
    #   IfreeSms::Manager.before_message do |env, opts|
    #   end
    #
    def before_message(options = {}, method = :push, &block)
      raise BlockNotGiven unless block_given?
      _before_message.send(method, [block, options])
    end
    
    # Provides access to the callback array for before_message
    # :api: private
    def _before_message
      @_before_message ||= []
    end
    
    # A callback that runs after message created
    # Example:
    #   IfreeSms::Manager.after_message do |env, opts|
    #   end
    #
    def after_message(options = {}, method = :push, &block)
      raise BlockNotGiven unless block_given?
      _after_message.send(method, [block, options])
    end
    
    # Provides access to the callback array for after_message
    # :api: private
    def _after_message
      @_after_message ||= []
    end
  end
end
