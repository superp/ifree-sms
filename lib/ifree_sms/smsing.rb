# encoding: utf-8
require "curb"

module IfreeSms
  module Smsing
    def self.included(base)
      base.send :include, InstanceMethods
      base.send :extend,  ClassMethods
    end
    
    module ClassMethods
      def self.extended(base)
        base.class_eval do
          # Associations
          belongs_to :messageable, :polymorphic => true
          
          # Validations
          validates :sms_id, :phone, :service_number, :sms_text, :now
          
          # Callbacks
          after_save :update_cached_columns
          after_destroy :update_cached_columns

          attr_accessible :request, :md5key
          
          scope :with_messageable, lambda { |record| where(["messageable_id = ? AND messageable_type = ?", record.id, record.class.name]) }
        end
      end
      
      def self.send_sms(phone, text, sms_id='noID')
        #http://srv1.com.ua/mcdonalds/second.php?smsId=noID&phone=380971606179&serviceNumber=3533&smsText=test-message&md5key=f920c72547012ece62861938b7731415&now=20110527160613
        params = {}
        params[:smsId] = sms_id
        params[:phone] = phone
        params[:serviceNumber] = IfreeSms::Config.config
        params[:phone] = phone
        params[:phone] = phone
        
        
        c = Curl::Easy.new("http://srv1.com.ua/#{@config.project_name}/second.php?#{to_url_params(params)}")
        
        c.perform
        puts c.body_str
      end
      
      protected
      
        def self.to_url_params(hash)
          elements = []
          hash.keys.size.times do |i|
            elements << "#{hash.keys[i]}=#{hash.values[i]}"
          end
          elements.join('&')
        end
      
 
    end
    
    module InstanceMethods
      
      def as_json(options = nil)
        options = { 
          :methods => [:ip], 
          :only => [:referrer, :value, :browser_version, :browser_name, :user_agent, :browser_platform ] 
        }.merge(options || {})
        
        super
      end
      
      def request
        @request
      end
      
      def request=(req)
        self.sms_id = req.params["smsId"]
        self.phone = req.params["phone"]
        self.service_number = req.params["serviceNumber"]
        self.sms_text = req.params["smsText"]
        self.now = req.params["now"]
        self.md5key = req.params["md5key"]
        self.messageable_id = messageable.class.find_by_sms_text(self.sms_text)
        
        @request = req
      end
      
      def config
        @config
      end
      
      def config=(conf)
        self.messageable_type = conf.routes[ @request.path_info ]
        
        @config = conf
      end
      
      def call 
        if register
          [self.to_json, 200]
        else
          [self.errors.to_json, 422]
        end
      end
      
      def register
        if messageable && messageable.ifree_sms_valid?(self)
          messageable.current_message = self
          
          messageable.run_callbacks(:message) do
            errors.empty? && save
          end
        end
      end
      
      protected
        
        def update_cached_columns
          if messageable && messageable.ifree_sms_cached_column
            count = messageable.messages.select("COUNT(id)")
            messageable.class.update_all("#{messageable.ifree_sms_cached_column} = (#{count.to_sql})", ["id = ?", messageable.id])
          end
        end
    end
  end
end
