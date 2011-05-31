# encoding: utf-8
require "curb"
require 'digest/md5'
require "base64"

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
          validate :check_secret_key

          attr_accessible :request
          attr_accessor :md5key, :test, :answer_text, :encoded_sms_text
          
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
        params[:smsText] = Base64.encode64(text)
        params[:now] = now
        params[:md5key] = calc_digest(IfreeSms.config.service_number, params[:smsText], now)
        
        
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
        self.encoded_sms_text = req.params["smsText"]
        self.now = parse_date(req.params["now"])
        self.md5key = req.params["md5key"]
        self.test = req.params["test"]
        
        @request = req
      end
      
      def encoded_sms_text=(value)
        self.sms_text = Base64.decode64(value) unless value.blank? 
        super
      end
      
      def to_ifree    
        if self.answer_text.blank?
          "<Response noresponse='true'/>"
        else
          "<Response><SmsText>#{Base64.encode64(self.answer_text)}</SmsText></Response>"
        end   
      end
      
      def test_to_ifree
        "<Response><SmsText>#{message.test}</SmsText></Response>"
      end
      
      def response_to_ifree
        unless self.new_record?
          [self.to_ifree, 200]
        else  
          [self.errors.to_json, 422]
        end
      end
      
      def test?
        !self.test.blank?
      end
      
      def send_answer(text)
        self.class.send_sms(self.phone, text, self.sms_id)
      end 
      
      protected
        
        def check_secret_key
          errors.add(:md5key, :invalid) unless valid_secret?
        end
        
        def valid_secret?
          return false if now.nil?
          
          self.md5key == self.class.calc_digest(service_number, encoded_sms_text, I18n.l(now, :format => "%Y%m%d%H%M%S"))
        end
        
        def parse_date(value)
          begin
            DateTime.parse(value)
          rescue Exception => e
            nil
          end
        end
    end
  end
end
