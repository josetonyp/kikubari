require 'fileutils'
require 'yaml'
require 'git'
require 'open3'

require "configuration/deploy_configuration"
require "deployer/deployer"
require "deployer/deployer_git"
require "deployer/deployer_git_wordpress"
require "deploy_dir"
require "deploy_logger"

module Kikubari
  class Deploy

    attr_accessor :config

    def initialize ( configuration  )
      @config = configuration
      return rollback if @config.rollback
      deploy
    end

    def deploy
      get_deployer( @config ).create_deploy_structure.deploy
    end

    def rollback
      @logger.print "rollingback"
    end

    def change( version )
      @logger.print "changing to version #{version}"
    end

    private

    def get_deployer config
      eval(config.get_deployer_class).new(config)
    end


  end

end
