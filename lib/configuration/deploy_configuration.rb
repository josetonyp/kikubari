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
        :environment,
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

        @deploy_file = YAML::load_file(file)

        @config = @deploy_file["config"] || {}
        @do = @deploy_file["do"] || {}
        @after = @deploy_file["after"] || {}
        @before = @deploy_file["before"] || {}

        raise ArgumentError, "There is no params for deploy" if params.size == 0

        ## verify all arguments for params are present
        @verbose = false

        params.first.each do |key,value|
          instance_variable_set "@#{key}".strip, value
        end

        unless File.directory? @deploy_folder
          raise ArgumentError , "Deploy folder #{@deploy_folder} is not a valid deploy folder"
        end

        @environment_folder = "#{@deploy_folder}/#{@environment}"
        @date_folder = DateTime.now.strftime("%Y%m%d%H%M%S%L")
        @env_time_folder = "#{@deploy_folder}/#{@environment}/#{@date_folder}"
        @current_deploy_folder = "#{@deploy_folder}/#{@environment}/current"

        parse_strcuture_folders if @do.has_key?("folder_structure") && !@do["folder_structure"].empty?
        parse_test_files if @do.has_key?("test_files") && !@do["test_files"].empty?

      end

      # Return a class name for create a deployer instance for deployment process
      def get_deployer_class
        fw_class = ( @config.has_key?("framework") ) ? @config["framework"].downcase.capitalize : ""
        fw_system = ( @config.has_key?("system") ) ? @config["system"].downcase.capitalize : ""
        "#{fw_class}#{fw_system}Deployer"
      end

      # Return a class name for create a backup worker instance for backup process
      def get_backup_class
        fw_class = ( @config.has_key?("framework") ) ? @config["framework"].downcase.capitalize : ""
        return "" unless @config.has_key?("database") && @config["database"].has_key?("driver")
        driver = @config["database"]["driver"].downcase.capitalize
        "#{fw_class}#{driver}Backup"
      end

      def get_structure_folder ( name )
        @do["folder_structure"].each do |folder|
          return folder.first[1] if folder.first[0] == name
        end
        ""
      end

      def get_test_file ( name )
        @do["test_files"].each do |folder|
          return folder.first[1] if folder.first[0] == name
        end
        ""
      end

      private

      def parse_strcuture_folders
        tmp = Array.new
        environment = @environment
        @do["folder_structure"].each do |folder|
           tmp.push Hash[ { folder[0] => "#{@deploy_folder}/#{eval(%Q["#{folder[1]}"])}"  } ]
        end
        @do["folder_structure"] = tmp
      end



      def parse_test_files
        tmp = Array.new
        environment = @environment
        @do["test_files"].each do |folder|
           tmp.push Hash[ { folder[0] => "#{@deploy_folder}/#{eval(%Q["#{folder[1]}"])}" } ]
        end
        @do["test_files"] = tmp
      end


    end

  end

end
