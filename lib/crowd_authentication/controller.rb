require "rest-client"
# use authenticate_with_crowd_id with email and password to authenticate by crowd id

module CrowdAuthentication
  module Controller

    def self.included(base)
      base.extend CrowdClassMethods
    end

    protected

    module CrowdClassMethods
      def after_authentication(*symbols)
        init_callbacks
        self.crowd_callbacks[:after] += symbols.map(&:to_sym)
      end

      def before_authentication(*symbols)
        init_callbacks
        self.crowd_callbacks[:before] += symbols.map(&:to_sym)
      end

      protected
      attr_accessor :crowd_callbacks

      def init_callbacks
        self.crowd_callbacks ||= {:before => [], :after => []}
      end
    end

    def authenticate_with_crowd_id(username, password)
      opts = {:password => password, :username => username}
      do_callbacks :before, opts

      resp = crowd_request("authentication", :data => {:value => opts[:password]}, :params => {:username => opts[:username]}, :method => :post)
      resp_hash = {:success => resp.code == 200, :code => resp.code, :body => ActiveSupport::JSON.decode(resp.body)}

      resp_hash.tap do
        do_callbacks :after, resp_hash
      end
    end

    def do_callbacks(trigger, arguments)
      self.class.send :init_callbacks
      (self.class.send :crowd_callbacks)[trigger.to_sym].each do |func|
        rails_logger.info "CROWD API: Triggering #{trigger} callback: #{func}"
        self.send func, arguments
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
               when :get     then RestClient.get(crowd_uri(action), opts)        {|response, request, result| response }
               when :put     then RestClient.put(crowd_uri(action), data, opts)  {|response, request, result| response }
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