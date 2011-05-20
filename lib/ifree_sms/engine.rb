# encoding: utf-8
require 'rails'
require 'ifree_sms'

module IfreeSms
  class Engine < ::Rails::Engine
    config.before_initialize do
      ActiveSupport.on_load :active_record do
        ::ActiveRecord::Base.send :include, IfreeSms::Base
      end
    end
  end
end
