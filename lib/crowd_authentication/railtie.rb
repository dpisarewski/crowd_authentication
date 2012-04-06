module CrowdAuthentication
  class Railtie < Rails::Railtie
    initializer "application_controller.initialize_crowd_authentication" do
      ActiveSupport.on_load(:action_controller) do
        include CrowdAuthentication::Controller
      end
    end
  end
end