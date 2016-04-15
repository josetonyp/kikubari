# Holds the deployment configuration for each deploy
#
# Author::    Jose A Pio  (mailto:josetonyp@gmail.com)
# Copyright:: Copyright (c) 2011
# License::   Distributes under the same terms as Ruby
module Kikubari
  class Deploy
    class Configuration

      attr_accessor :deploy_folder,
        :debug,
        :dry_run,
        :rollback,
        :deploy_file,
        :config,
        :do ,
        :environment_folder,
        :env_time_folder,
        :current_deploy_folder,
        :date_folder,
        :after,
        :before,
        :verbose

      def initialize( file , *params )

        unless File.exist?(file)
          raise "Deploy guide file doesn't exists: #{file}"
        end

        @deploy_file = parse_config_file(file)

        @config = @deploy_file.config || {}
        @do = @deploy_file.do || {}
        @after = @deploy_file.after
        @before = @deploy_file.before

        raise ArgumentError, "There is no params for deploy" if params.size == 0

        ## verify all arguments for params are present
        @verbose = false

        params.first.each do |key,value|
          instance_variable_set "@#{key}".strip, value
        end

        unless File.directory? @deploy_folder
          raise ArgumentError , "Deploy folder #{@deploy_folder} is not a valid deploy folder"
        end

        @environment_folder = @deploy_folder.join "releases"
        @date_folder = DateTime.now.strftime("%Y%m%d%H%M%S%L")
        @env_time_folder = @environment_folder.join @date_folder
        @current_deploy_folder = @environment_folder.join "current"
      end

      # Return a class name for create a deployer instance for deployment process
      def get_deployer_class
        fw_class = ( @config.framework ) ? @config.framework.downcase.capitalize : ""
        fw_system = ( @config.system ) ? @config.system.downcase.capitalize : ""
        "#{fw_class}#{fw_system}Deployer"
      end

      private

      def parse_config_file(file)
        @deploy_file = YAML::load_file(file)
        JSON.parse(@deploy_file.to_json, object_class: OpenStruct)
      end


    end

  end

end
