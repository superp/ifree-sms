# encoding: utf-8
require "curb"
require 'digest/md5'

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
          validates :sms_id, :phone, :service_number, :sms_text, :now, :presence => true

          attr_accessible :request
          attr_accessor :md5key, :test, :answer_text
          
          scope :with_messageable, lambda { |record| where(["messageable_id = ? AND messageable_type = ?", record.id, record.class.name]) }
        end
      end
      
      def send_sms(phone, text, sms_id='noID')
        #http://srv1.com.ua/mcdonalds/second.php?smsId=noID&phone=380971606179&serviceNumber=3533&smsText=test-message&md5key=f920c72547012ece62861938b7731415&now=20110527160613
        
        now = I18n.l(DateTime.now, :format => "%Y%m%d%H%M%S")
        
        params = {}
        params[:smsId] = sms_id
        params[:phone] = phone
        params[:serviceNumber] = IfreeSms.config.service_number
        params[:smsText] = text
        params[:now] = now
        params[:md5key] = calc_digest(IfreeSms.config.service_number, text, now)
        
        
        c = Curl::Easy.new("http://srv1.com.ua/#{IfreeSms.config.project_name}/second.php?#{Rack::Utils.build_query(params)}")
        
        c.perform
        c.body_str
      end
      
      def calc_digest(number, text, now)
        Digest::MD5.hexdigest(number.to_s + text.to_s + IfreeSms.config.secret_key + now.to_s)
      end
 
    end
    
    module InstanceMethods
      
      def request
        @request
      end
      
      def request=(req)
        self.sms_id = req.params["smsId"].to_i
        self.phone = req.params["phone"].to_i
        self.service_number = req.params["serviceNumber"].to_i
        self.sms_text = req.params["smsText"]
        self.now = req.params["now"]
        self.md5key = req.params["md5key"]
        self.test = req.params["test"]
        #self.messageable = messageable.class.find_by_sms(self)
        
        @request = req
      end
      
      def to_ifree        
        answer = self.test.blank? ? self.answer_text : self.test
        
        if self.answer_text.blank? && self.test.blank?
          "<Response noresponse='true'/>"
        else
          "<Response><SmsText>#{answer}</SmsText></Response>"
        end   
      end
      
      def call        
        if secret_check? && errors.empty? && save
          [self.to_ifree, 200]
        else
          [self.errors.to_json, 422]
        end
      end
      
      
      protected
        
        def secret_check?
          self.md5key == self.class.calc_digest(self.service_number, self.sms_text, I18n.l(self.now, :format => "%Y%m%d%H%M%S"))
        end
    end
  end
end
