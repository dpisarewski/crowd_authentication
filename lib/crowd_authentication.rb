require "crowd_authentication/controller"

config.after_initialize do
  ApplicationController.send(:include, CrowdAuthentication::Controller)
end
