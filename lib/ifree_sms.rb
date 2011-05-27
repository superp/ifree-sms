module IfreeSms
  autoload :Smsing,    'ifree_sms/smsing'
  autoload :Manager,   'ifree_sms/manager'
  autoload :Config,    'ifree_sms/config'
  autoload :Callbacks, 'ifree_sms/callbacks'
  autoload :Base,      'ifree_sms/base'
  
  mattr_accessor :config
  @@config = Config.new
  
  def self.configure(&block)
    yield config
  end
  
  def self.table_name_prefix
    'ifree_sms_'
  end
 
end

require 'ifree_sms/engine' if defined?(Rails)
