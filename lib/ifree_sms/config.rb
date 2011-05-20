# encoding: utf-8
module IfreeSms
  class Config < Hash
    # Creates an accessor that simply sets and reads a key in the hash:
    #
    # class Config < Hash
    #   hash_accessor :routes, :secret_key
    # end
    #
    # config = Config.new
    # config.routes = {'/posts/message' => 'Post' }
    # config[:routes] #=> {'/posts/message' => 'Post' }
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
    
    hash_accessor :routes, :secret_key
    
    def initialize(other={})
      merge!(other)
      self[:routes] ||= { "/ifree_sms/message" => 'Class' }
      self[:secret_key] ||= "some_very_secret_key_given_ifree"
    end
  end
end
