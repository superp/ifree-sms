module IfreeSms
  module Base
    def self.included(base)
      base.extend SingletonMethods
    end
    
    module SingletonMethods
      #
      #  ifree_sms :counter_cache => true
      #
      def ifree_sms(options = {})
        extend ClassMethods
        include InstanceMethods
        
        class_attribute :ifree_sms_options, :instance_writer => false
        self.ifree_sms_options = options
        
        has_many :messages,
          :class_name => 'IfreeSms::Message', 
          :as => :messageable,
          :dependent => :nullify
        
        define_ifree_sms_callbacks :massage
      end
    end
    
    module ClassMethods
    
      def define_ifree_sms_callbacks(*callbacks)
        define_callbacks *[callbacks, {:terminator => "result == false"}].flatten
        callbacks.each do |callback|
          eval <<-end_callbacks
            def before_#{callback}(*args, &blk)
              set_callback(:#{callback}, :before, *args, &blk)
            end
            def after_#{callback}(*args, &blk)
              set_callback(:#{callback}, :after, *args, &blk)
            end
          end_callbacks
        end
      end
      
      def ifree_sms_cached_column
        if ifree_sms_options[:counter_cache] == true
          "sms_messages_count"
        elsif ifree_sms_options[:counter_cache]
          ifree_sms_options[:counter_cache]
        else
          false
        end
      end
    end
    
    module InstanceMethods
      
      def ifree_sms_cached_column
        @ifree_sms_cached_column ||= self.class.ifree_sms_cached_column
      end
      
    end
  end
end
