module IfreeSms
  class Message < ::ActiveRecord::Base
    include IfreeSms::Smsing
  end
end
