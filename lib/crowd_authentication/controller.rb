require "rest-client"
# use authenticate_with_crowd_id with email and password to authenticate by crowd id

module CrowdAuthentication
  module Controller

    protected
    def self.after_authentication(&block)
      @crowd_callbacks ||= {}
      @crowd_callbacks[:after] << block
    end

    def self.before_authentication(&block)
      @crowd_callbacks ||= {}
      @crowd_callbacks[:before] << block
    end

    def authenticate_with_crowd_id(username, password)
      opts = {:password => password, :username => username}
      @crowd_callbacks[:before].each{|b| b.call opts}
      resp = crowd_request("authentication", :data => {:value => opts[:password]}, :params => {:username => opts[:username]}, :method => :post)
      resp_hash = {:success => resp.code == 200, :code => resp.code, :body => ActiveSupport::JSON.decode(resp.body)}
      resp_hash.tap do
        @crowd_callbacks[:after].each{|b| b.call resp_hash}
      end
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
      options = {:format => :json, :method => :get}.merge(options)
      if options[:data]
        data = case options[:format].to_sym
                 when :json then options[:data].to_json
                 when :xml then options[:data].to_xml
                 else options[:data]
               end
      end
      opts = {:params => options[:params], :content_type => options[:format], :accept => options[:format]}

      rails_logger.info "CROWD API: sending request #{crowd_uri(action).gsub(/[\w\d\-_]+:[\w\d\-_]+@/, '')}"

      resp = case options[:method].to_sym
        when :post    then RestClient.post(crowd_uri(action), data, opts) {|response, request, result| response }
        when :get     then RestClient.get(crowd_uri(action), opts) {|response, request, result| response }
        when :put     then RestClient.put(crowd_uri(action), data, opts) {|response, request, result| response }
        when :delete  then RestClient.delete(crowd_uri(action))
      end

      resp.tap do
        rails_logger.info "CROWD API: response code #{resp.code}"
        rails_logger.info "CROWD API: response body #{resp.body}"
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