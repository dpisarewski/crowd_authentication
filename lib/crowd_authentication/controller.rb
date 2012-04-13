require "rest-client"
# use authenticate_with_crowd_id with email and password to authenticate by crowd id

module CrowdAuthentication
  module Controller

    protected
    def authenticate_with_crowd_id(username, password)
      resp = crowd_request("authentication", :data => {:value => password}, :params => {:username => username})
      resp.code == 200
    end

    def crowd_user_data(username)
      resp = crowd_request("user", :params => {:username => username})
      ActiveSupport::JSON.decode resp.body
    end

    def crowd_uri(action)
      "http://#{crowd_config[:application_name]}:#{crowd_config[:application_password]}@#{crowd_config[:host]}:#{crowd_config[:port]}/#{crowd_config[:api_path]}/#{action}"
    end

    # Sends REST API request to crowd server
    # @param [Hash] options Optional data to be send
    # options[:data] includes request body
    # options[:format] default value is :json. possible values :json, :xml, :text
    # @return [Object] response object
    def crowd_request(action, options = {})
      options = {:format => :json}.merge(options)
      data = case options[:format].to_sym
               when :json then options[:data].to_json
               when :xml then options[:data].to_xml
               else options[:data]
             end
      rails_logger.info "CROWD API: sending request #{crowd_uri(action).gsub(/w+:w+@/, '')}"
      resp = RestClient.post(crowd_uri(action),
                      data,
                      :params       => options[:params],
                      :content_type => options[:format],
                      :accept       => options[:format]) {|response, request, result| response }
      resp.tap do
        rails_logger.info "CROWD API: response code #{resp.code}"
      end
    end

    private
    def crowd_config
      @crowd_authentication_config ||= YAML::load_file(File.join(rails_root, "config", "crowd_authentication.yml"))['crowd_server'].symbolize_keys or raise Exception.new("Error on loading configuration file for crowd_authentication")
    end

    def rails_root
      if defined?(Rails) then Rails.root elsif defined?(RAILS_ENV) then RAILS_ENV end
    end

    def rails_logger
      if defined?(Rails) then Rails.logger elsif defined?(RAILS_DEFAULT_LOGGER) then RAILS_DEFAULT_LOGGER end
    end
  end

end