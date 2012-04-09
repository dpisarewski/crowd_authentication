require "rest-client"
# use authenticate_with_crowd_id with email and password to authenticate by crowd id

module CrowdAuthentication
  module Controller

    protected
    def authenticate_with_crowd_id(username, password)
      resp = crowd_request("authentication", :data => {:value => password}, :params => {:username => username})
      rails_logger.info "CROWD API: response code #{resp.code}"
      resp.code == 200
    end

    def crowd_uri(action)
      url_for :user       => crowd_config[:application_name],
              :password   => crowd_config[:application_password],
              :host       => crowd_config[:host],
              :port       => crowd_config[:port],
              :controller => crowd_config[:api_path],
              :action     => action,
              :only_path  => false
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
      RestClient.post(crowd_uri(action),
                      data,
                      :params       => options[:params],
                      :content_type => options[:format],
                      :accept       => options[:format]) {|response, request, result| response }
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