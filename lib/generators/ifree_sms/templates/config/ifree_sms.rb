# config/initializers/ifree_sms.rb
if Object.const_defined?("IfreeSms")

  IfreeSms.setup do |config|
    config.secret_key = ""
    config.project_name = ""
    config.service_number = ""
  end

  IfreeSms::Manager.before_message do |env, message|
    # set it if you want to send answer for user
    message.answer_text = "put here sms answer for user"
  end

  IfreeSms::Manager.after_message do |env, message|

  end
end
