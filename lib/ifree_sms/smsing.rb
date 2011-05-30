# encoding: utf-8
require "curb"
require 'digest/md5'
require 'uri'

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

          attr_accessible :request, :md5key, :test
          
          scope :with_messageable, lambda { |record| where(["messageable_id = ? AND messageable_type = ?", record.id, record.class.name]) }
        end
      end
      
      def self.send_sms(phone, text, sms_id='noID')
        #http://srv1.com.ua/mcdonalds/second.php?smsId=noID&phone=380971606179&serviceNumber=3533&smsText=test-message&md5key=f920c72547012ece62861938b7731415&now=20110527160613
        now = I18n.l(DateTime.now, :format => "%Y%m%d%H%M%S")
        
        params = {}
        params[:smsId] = sms_id
        params[:phone] = phone
        params[:serviceNumber] = IfreeSms.config.service_number
        params[:smsText] = text
        params[:now] = now
        params[:md5key] = calc_digest(IfreeSms.config.service_number, text, IfreeSms.config.secret_key, now)
        
        
        c = Curl::Easy.new("http://srv1.com.ua/#{@config.project_name}/second.php?#{to_url_params(params)}")
        
        c.perform
        puts c.body_str
      end
      
      protected
      
        def self.to_url_params(hash)
          elements = []
          hash.keys.size.times do |i|
            val = URI.escape(hash.values[i], Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
            elements << "#{hash.keys[i]}=#{val}"
          end
          elements.join('&')
        end
        
        def self.calc_digest(number, text, secret, now)
          Digest::MD5.hexdigest(number + text + secret + now)
        end
 
    end
    
    module InstanceMethods
      
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
        self.test = req.params["test"]
        self.messageable = messageable.class.find_by_sms(self)
        
        @request = req
      end
      
      def to_ifree
        answer = self.test.blank? ? "test answer" : self.test
        
        "<Response><SmsText>#{answer}</SmsText></Response>"
      end
      
      def call 
        if (secret_check? && errors.empty?) && (register || save)
          [self.to_ifree, 200]
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
        
        def secret_check?
          self.md5key == self.class.calc_digest(self.service_number, self.sms_text, IfreeSms.config.secret_key, self.now)
        end
    end
  end
end
