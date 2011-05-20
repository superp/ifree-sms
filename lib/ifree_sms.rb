module IfreeSms
  autoload :Smsing,    'ifree_sms/smsing'
  autoload :Manager,   'ifree_sms/manager'
  autoload :Config,    'ifree_sms/config'
  autoload :Callbacks, 'ifree_sms/callbacks'
  autoload :Base,      'ifree_sms/base'
  
  module Strategies
    autoload :Base,          'ifree_sms/strategies/base'
    autoload :Authenticated, 'ifree_sms/strategies/authenticated'
  end
  
  def self.table_name_prefix
    'ifree_sms_'
  end
  
  def self.load_strategy(name)
    case name.class.name
      when "Symbol" then "BallotBox::Strategies::#{name.to_s.classify}".constantize
      when "String" then name.classify.constantize
      else name
    end
  end
end

require 'ifree_sms/engine' if defined?(Rails)
