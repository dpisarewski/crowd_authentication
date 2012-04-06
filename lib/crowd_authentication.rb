require "crowd_authentication/controller"

ApplicationController.send(:include, CrowdAuthentication::Controller)