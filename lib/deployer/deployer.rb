require 'json'
require 'ostruct'

# Describe the deployment process for each deployer
#
# Basically a deployment consist on gathering the code from a <b>Repository</b> writed in a <b>Framework</b> (In some language) and copying on deployment folder.
#
# On deployment config (<em>deploy.yml</em>) can be setted the actions to be done one the code gathering is successfull. Then tipically the system would make come backups task, link some folder and files.
#
# Author::    Jose A Pio  (mailto:josetonyp@gmail.com)
# Copyright:: Copyright (c) 2011
# License::   Distributes under the same terms as Ruby
module Kikubari
  class Deploy
    class Deployer

      attr_accessor :config

      def initialize(config)
        @config = config
        @logger = Logger.new
      end

      ##
      # Create te the folder structure as is in the YAML
      #
      def create_structure
        @config.do.folder_structure.each_pair do |folder, target_folder|
          unless !target_folder.empty? && File.directory?(@config.deploy_folder.join(folder.to_s))
            @logger.print "Creating Structure folder: #{folder}"
            FileUtils.mkdir_p @config.deploy_folder.join(folder.to_s)
          end
        end
        self
      end

      ##
      # Create the folder where you will deploy the actual version of the code based on the configuration
      #
      def create_release_folder
        FileUtils.mkdir_p(@config.env_time_folder) unless File.directory? @config.env_time_folder
        self
      end

      ##
      # Create the current symlink to the deploy version folder
      #
      def create_current_symlink_folder
        FileUtils.rm_f(@config.current_deploy_folder) if File.symlink?(@config.current_deploy_folder)
        FileUtils.ln_s @config.env_time_folder, @config.current_deploy_folder
        self
      end


      ##
      # Test if selected file already exist
      #
      def test_files
        @config.do.link_files.each_pair do |source, target|
          unless File.exist? @config.deploy_folder.join(source.to_s)
            raise ArgumentError, "Please verify this file exist: #{@config.deploy_folder.join(source.to_s)}"
          end
        end
        self
      end

      ##
      # Create the Symlinked folders
      #
      def create_sylinked_folders
        @config.do.folder_structure.each_pair do |folder, target_folder|
          next if target_folder.empty?
          @logger.print "- linking: #{@config.env_time_folder}/#{target_folder}"
          raise "Folder: #{@config.env_time_folder.join(target_folder.to_s)} already exists and the symlink can't be created" if File.directory?(@config.env_time_folder.join(target_folder.to_s))
          create_symlink( @config.deploy_folder.join(folder.to_s), @config.env_time_folder.join(target_folder.to_s) )
        end
        self
      end

      ##
      # Execute creation of symlinked folder
      #
      def create_symlink( folder, target_folder )
        raise ArgumentError , "Origin folder #{folder} is not a valid folder" unless File.directory?(folder)
        FileUtils.ln_s folder, target_folder
      end


      def create_symlinked_files
        @logger.print "Creating Files symbolic links"
        @config.do.link_files.each_pair do |source, target|
          FileUtils.ln_s(@config.deploy_folder.join(source.to_s), @config.env_time_folder.join(target.to_s))
        end
      end


      ##
      # Create deployment structure
      #
      def create_deploy_structure
        create_structure if @config.do.folder_structure
        self
      end

      ##
      # Rotate old version folders
      #
      def rotate_folders
        DeployDir.rotate_folders( @config.environment_folder , @config.config["history_limit"] )
      end


      def has_after_deploy_run_commands
        @config.after && @config.after.run && !@config.after.run.empty?
      end

      ##
      # Run comand line script after deploy
      #
      def after_deploy_run
        return unless has_after_deploy_run_commands
        out = Array.new
        @logger.head "Executing After Deploy"
        @config.after.run.each do |run_task|
          out.push(execute_shell(run_task) )
        end
        out
      end

      def has_before_deploy_run_commands
        @config.before && @config.before.run && !@config.before.run.empty?
      end

      def before_deploy_run
        return unless has_before_deploy_run_commands
        out = Array.new
        @logger.head "Executing Before Deploy"
        @config.before.run.each do |run_task|
          out.push(execute_shell(run_task) )
        end
        out
      end

      def execute_shell(command)
        @logger.run(command, @config.env_time_folder)
        temp = capture_stderr "cd #{@config.env_time_folder.to_s.strip} && #{command} "
        @logger.result(temp[:stdout]) if temp[:stdout] != ""
        @logger.error(temp[:stderr]) if temp[:stderr] != ""
        temp
      end


      def capture_stderr ( command )
       stdin, stdout, stderr = Open3.popen3( command )
       ({ :stdout => stdout.readlines.join(""), :stderr => stderr.readlines.join("") })
      end

      ##
      # Execute the deploy
      #
      def deploy
          before_deploy_run
        @logger.head "Executing Deploy"
        test_files  if @config.do.test_files && !@config.do["test_files"].empty?
          do_deploy
        create_sylinked_folders if @config.do.folder_symbolic_links && !@config.do["folder_symbolic_links"].empty?
        create_symlinked_files if @config.do.file_symbolic_link && !@config.do["file_symbolic_link"].empty?
        create_current_symlink_folder
        rotate_folders
          after_deploy_run
        self
      end

      private

      def do_deploy
        raise "This is an abstract method, implement this method in your deployer"
      end

    end
  end
end
