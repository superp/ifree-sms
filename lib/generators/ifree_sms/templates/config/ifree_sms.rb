# Use this hook to configure IfreeSms
if Object.const_defined?("IfreeSms")

  IfreeSms.setup do |config|
    config.secret_key = ""
    config.project_name = ""
    config.service_number = ""
  end
  
  # Initialize IfreeSms and set its configurations.
  config.app_middleware.use IfreeSms::Manager do |config|
    config.routes = { "/ifree/sms" => "Post" }
  end
end
