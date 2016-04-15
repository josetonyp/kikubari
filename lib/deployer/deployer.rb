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
        @config.do["folder_structure"].each do |command|
          unless File.directory? command.first[1]
            @logger.print "Creating Structure folder: #{command.first[1]}"
            FileUtils.mkdir_p command.first[1]
          end
        end
        self
      end


      ##
      # Create the environment folder as requested in the configuration
      #
      def create_environment_folder
        environment = @config.environment
        unless File.directory? @config.environment_folder
          @logger.print "Creating Environment folder: #{ @config.environment_folder}"
          FileUtils.mkdir_p  @config.environment_folder
        end
        self
      end

      ##
      # Create the folder where you will deploy the actual version of the code based on the configuration
      #
      def create_version_folder
        FileUtils.mkdir_p(@config.env_time_folder) unless File.directory? @config.env_time_folder
        self
      end

      ##
      # Create the current symlink to the deploy version folder
      #
      def create_current_symlink_folder
        destination = @config.current_deploy_folder
        origin =  Pathname.new( @config.env_time_folder ).relative_path_from( Pathname.new( @config.current_deploy_folder.gsub(/\/[^\/]*?$/, "") ) ).to_s
        FileUtils.rm_f(destination) if File.symlink?(destination)
        FileUtils.ln_s origin, destination
        self
      end


      ##
      # Test if selected file already exist
      #
      def test_files
        @config.do["test_files"].each do |command|
          y command
          unless File.exist? command.first[1]
            raise "Please verify this file exist: #{command.first[1]}"
          end
        end
        self
      end

      ##
      # Create the Symlinked folders
      #
      def create_sylinked_folders
          @config.do["folder_symbolic_links"].each do |folder|
            @logger.print "- linking: #{@config.env_time_folder}/#{folder[1]}"
            raise "Folder: #{@config.env_time_folder}/#{folder[1]} already exists and the symlink can't be created" if File.directory?("#{@config.env_time_folder}/#{folder[1]}")
            create_symlink( folder )
          end
          self
      end

      ##
      # Execute creation of symlinked folder
      #
      def create_symlink( folder )
        destination = "#{@config.env_time_folder}/#{folder[1]}"
        raise ArgumentError , "Origin folder #{@config.get_structure_folder(folder[0])} is not a valid folder" unless File.directory?("#{@config.get_structure_folder(folder[0])}")
        origin = Pathname.new( "#{@config.get_structure_folder(folder[0])}" ).relative_path_from( Pathname.new( destination.gsub(/\/[^\/]*?$/, "") ) ).to_s  ## Origin as a relative path from destination
        FileUtils.ln_s origin, destination
      end

      def create_symlinked_files
        @logger.print "Creating Files symbolic links"
        @config.do["file_symbolic_link"].each do |folder|
          destination = "#{@config.env_time_folder}/#{folder[1]}"
          origin = Pathname.new( "#{@config.get_test_file(folder[0])}" ).relative_path_from(Pathname.new( destination.gsub(/\/[^\/]*?$/, "") )).to_s
          FileUtils.ln_s  origin , destination
        end
      end


      ##
      # Create deployment structure
      #
      def create_deploy_structure
        create_structure if @config.do.has_key?("folder_structure") && !@config.do["folder_structure"].empty?
        create_environment_folder.create_version_folder
        self
      end

      ##
      # Rotate old version folders
      #
      def rotate_folders
        DeployDir.rotate_folders( @config.environment_folder , @config.config["history_limit"] )
      end


      def has_after_deploy_run_commands
        @config.after.has_key?("run") && !@config.after["run"].empty?
      end

      ##
      # Run comand line script after deploy
      #
      def after_deploy_run
        return unless has_after_deploy_run_commands
        out = Array.new
        @logger.head "Executing After Deploy"
        @config.after["run"].each do |run_task|
          out.push(execute_shell(run_task) )
        end
        out
      end


      def has_before_deploy_run_commands
        @config.before.has_key?("run") && !@config.before["run"].empty?
      end

      def before_deploy_run
        return unless has_before_deploy_run_commands
        out = Array.new
        @logger.head "Executing Before Deploy"
        @config.before["run"].each do |run_task|
          out.push(execute_shell(run_task) )
        end
        out
      end

      def execute_shell(command)
        @logger.run(command, @config.env_time_folder)
        temp = capture_stderr "cd #{@config.env_time_folder} ; #{command} "
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
        test_files  if @config.do.has_key?("test_files") && !@config.do["test_files"].empty?
          do_deploy
        create_sylinked_folders if @config.do.has_key?("folder_symbolic_links") && !@config.do["folder_symbolic_links"].empty?
        create_symlinked_files if @config.do.has_key?("file_symbolic_link") && !@config.do["file_symbolic_link"].empty?
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
