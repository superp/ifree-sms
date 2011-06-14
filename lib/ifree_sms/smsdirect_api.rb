module IfreeSms
  module SMSDirectAPIMethods
    SMSDIRECT_SERVER = "https://www.smsdirect.ru"
  
    # Send SMS message
    # Sample request:
    #  GET /submit_message?login=demo&pass=demo&from=test&to=380503332211&text=smsdirect_submit_sm
    #
    def submit_message(phone, text, from = 'test')
      call("submit_message", {:from => from, :to => phone, :text => text})
    end
    
    # Получение статуса сообщения
    # Параметры запроса:
    # mid - ID сообщения полученный с помощью вызова submit_message
    #
    def status_message(message_id)
      call("status_message", {:mid => message_id})
    end
    
    # Создание/обновление базы абонентов
    # Параметры запроса: 
    # id - ID базы (может быть пустым при создании новой базы); 
    # lname - название базы (может быть пустым);
    # qfile - список записей разделенных переводом строк, со следующими полями (поля разделяются знаком ;):
    # msisdn;name;secondname;lastname;city;date;sex
    # поле msisdn - номер телефона абонента;
    # поля name;secondname;lastname;city;sex - текстовые, по указанным именам их можно использовать в п.8 в поле mess, для      подстановки значений (при указании поля pattern = 1);
    # поле date - дата в формате ДД-ММ-ГГГГ;
    # 
    def submit_db(uid, qfile, name = '')
      call("submit_db", {:id => uid, :qfile => qfile, :lname => name})
    end
    
    # Удаление записей из базы абонентов
    # Параметры запроса: 
    # id - ID базы;
    # msisdn - список номеров телефонов подлежащих удалению, разделенные запятой (,).
    #
    def edit_db(uid, phones)
      call('edit_db', {:id => uid, :msisdn => phones.join(',')})
    end

    # Получение статуса базы
    # Параметры запроса: 
    # id - ID базы; 
    #
    def status_db(uid)
      call('status_db', {:id => uid})
    end
    
    # Получение списка созданных баз
    #
    def get_db
      call("get_db")  
    end
    
    # Удаление базы
    # Параметры запроса: 
    # id - ID базы подлежащей удалению;
    #
    def delete_db(uid)
      call("delete_db", {:id => uid})
    end
    
    # Отправка смс-рассылки по созданной базе пользователей
    # Параметры запроса: 
    # typelist – тип данных (значения: 1 - база, 2 - список телефонов)
    # list - ID базы\выборки;
    # msisdn - список телефонов через запятую “,”
    # mess - текст сообщения, в случае если параметр pattern=1, название полей для последующей подстановки, 
    #  необходимо использовать в виде %ИМЯ ПОЛЯ%. Например, подстановка поля name будет выглядеть следующим образом: 
    #  «Уважаемый %name% поздравляем Вас с днём рождения.»;
    # isurl - признак wap-push (значения: 0 - отправлять как обычное сообщение, 1 - отправлять сообщения как push);
    # wappushheader - заголовок wap-push (в случае если тип isurl = 1);
    # max_mess - максимальное количество сообщений в день, оставить пустым, если не ограничено;
    # max_mess_per_hour - максимальное количество сообщений в час, оставить пустым, если не ограничено;
    def submit_dispatch(params = {})
      call('submit_dispatch', params)
    end
      
    protected
    
      def call(method_name, args = {}, options = {}, verb = "get")
        options = options.merge!(:smsdirect_api => true)

        api("#{SMSDIRECT_SERVER}/#{method_name}", args, verb, options) do |response|
          # check for REST API-specific errors
          if response.is_a?(Hash) && response["error_code"]
            raise APIError.new("type" => response["error_code"], "message" => response["error_msg"])
          end
        end
      end
  end
end
