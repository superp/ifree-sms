# encoding: utf-8
module IfreeSms
  class Config < Hash
    # Creates an accessor that simply sets and reads a key in the hash:
    #
    # class Config < Hash
    #   hash_accessor :routes, :secret_key, :service_number, :project_name
    # end
    #
    # config = Config.new
    # config.routes = '/posts/message'
    # config[:routes] #=> '/posts/message'
    #
    def self.hash_accessor(*names) #:nodoc:
      names.each do |name|
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{name}
            self[:#{name}]
          end

          def #{name}=(value)
            self[:#{name}] = value
          end
        METHOD
      end
    end
    
    hash_accessor :routes, :secret_key, :service_number, :project_name, :login, :password, :debug
    
    def initialize(other={})
      merge!(other)
      self[:routes] ||= "/ifree/sms"
      self[:secret_key] ||= "some_very_secret_key_given_ifree"
      self[:service_number] ||= "some_service_number"
      self[:project_name] ||= "project_name"
      self[:login] ||= "demo"
      self[:password] ||= "demo"
      self[:debug] ||= false
    end
    
    def url
      "http://srv1.com.ua/#{self[:project_name]}/second.php"
    end
  end
end
