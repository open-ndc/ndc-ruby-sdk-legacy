module NDCClient

  class Base
    # attr_accessor :endpoint, :wsdl, :status, :errors
    ATTRIB_CONVERTER = lambda {|key, value| [key, value]}

    def initialize(config = {})
      if config.is_a?(Hash) && config["soap"]
        @ndc_label = config["provider"]["iata-code"]
        @options = config["options"]
        @status = :initialized
        @soap_config = config["soap"]
        logger = Logger.new("./log/soap-#{@ndc_label}.log")
        @client = Savon::Client.new(
          wsdl: nil,
          endpoint: @soap_config["endpoint"],
          namespace: @soap_config["namespace"],
          body_namespace: @soap_config["bodyNamespace"],
          headers: @soap_config["headers"],
          soap_header: @soap_config["soap-header"],
          env_namespace: @soap_config["envelope"] ? @soap_config["envelope"].to_sym : nil,
          no_message_tag: true,
          convert_request_keys_to: :none,
          convert_attributes_to: nil,
          namespace_identifier: nil,
          convert_response_tags_to: nil,
          log: true,
          logger: logger
        )
      end
    end

    def request(method, params)
      case method
      when :AirShopping
        wrappers = {open: @soap_config['body-wrap-open'], close: @soap_config['body-wrap-close']} if @soap_config['body-wrap-open'] && @soap_config['body-wrap-close']
        soap_message = Messages::AirShoppingRQ.new(params, @options, wrappers)
        soap_call_with_message(method, soap_message)
        if @soap_config['response-body-wraps']
          begin
            @soap_config['response-body-wraps'].each{|wrap|
                @response = @response.fetch(wrap.to_sym)
            }
          rescue
            raise NDCErrors::NDCWrongBodyWrapping, "Unexpected body wrapping in response."
          end
        end
        if @response[:AirShoppingRS]
          return @response
        else
          raise NDCErrors::NDCInvalidResponseFormat, "Expecting an AirShoppingRS Document"
        end
      else
        raise NDCErrors::NDCUnknownMethod, "Method #{method} is unknown."
      end
    end

    def response
      @response
    end

    private

    def soap_call_with_message(method, message)
      @method = method
      @status = :request_sent
      response = @client.call(method, message: message.to_xml_with_body_wrap)
      @status = :request_complete
      @response = response.body
    end

  end

end
