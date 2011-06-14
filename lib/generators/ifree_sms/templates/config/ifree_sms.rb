# config/initializers/ifree_sms.rb
if Object.const_defined?("IfreeSms")

  IfreeSms.setup do |config|
    config.secret_key = ""
    config.project_name = ""
    config.service_number = ""
    config.login = ""
    config.password = ""
    config.debug = true
  end

  IfreeSms::Manager.incoming_message do |env, message|  
    # set it if you want to send answer for user
    message.answer_text = "put here sms answer for user"
  end
end
