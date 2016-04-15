require 'spec_helper'

describe Kikubari::Deploy::Deployer do

  let(:config) do
    Kikubari::Deploy::Configuration.new(
      "#{RSpec.configuration.deploy_files}/deploy_symlink.yml",
      deploy_folder: RSpec.configuration.target_folder,
      debug: false,
      dry_run: false,
      environment: 'production',
      rollback: false)
  end

  subject(:subject) { described_class.new(config) }

  before :all do
    clear_target_project
  end

  context 'Folder Structure' do

    it "creates an environment folder to host the structure" do
      expect(subject.create_environment_folder).to satisfy do |deployer|
        File.directory?(deployer.config.environment_folder)
      end
    end

    it "creates a target version folder with a the current time stamp as name" do
      expect(subject.create_version_folder).to satisfy do |deployer|
        File.directory?(deployer.config.env_time_folder)
      end
    end

    it "createa a symlink 'current' to the actual target version folder" do
      expect(subject.create_version_folder.create_current_symlink_folder).to satisfy do |deployer|
        File.symlink?(deployer.config.current_deploy_folder)
      end
    end

    # Giving a folder structure like:
    # From file: spec/deploy_files/deploy_symlink.yml
    #
    #  folder_structure:
    #    cache: 'cache/#{environment}'
    #    config: 'config/#{environment}'
    #
    # Example:
    # project:
    #   cache
    #     [environment]
    #   config
    #     [environment]
    #   [environment]
    #     [version_folder]
    #       cache: Symlink to cache/[environment]
    #       config: Symlink to config/[environment]
    #     current: Symlink to [version_folder]
    #
    it "creates the cache and condig folder inside" do
      subject.tap do |deployer|
        deployer.create_environment_folder
        deployer.create_version_folder
        deployer.create_current_symlink_folder

        expect(deployer.create_structure).to satisfy do
          File.directory?("#{deployer.config.deploy_folder}/cache/#{deployer.config.environment}") &&
          File.directory?("#{deployer.config.deploy_folder}/config/#{deployer.config.environment}")
        end
      end
    end

    it "creates a symlink to inside the version folder pointing to the corresponding folder inside the structure" do
      subject.tap do |deployer|
        deployer.create_environment_folder
        deployer.create_version_folder
        deployer.create_structure

        expect(deployer.create_sylinked_folders).to satisfy do
          File.symlink?( "#{deployer.config.env_time_folder}/cache") &&
          File.symlink?( "#{deployer.config.env_time_folder}/config")
        end
      end
    end

    it "should not create the symlinked folder is folder already exist" do
      subject.create_environment_folder.create_version_folder.create_current_symlink_folder
      subject.create_structure
      FileUtils.mkdir_p "#{config.env_time_folder}/cache"
      expect {
        subject.create_sylinked_folders
      }.to raise_error
    end
  end

  context 'File linking' do
    it "verifies a file in the folder and raise an error" do
      subject.create_environment_folder.create_version_folder.create_current_symlink_folder
      expect{subject.test_files}.to raise_error
    end

    it "verifies a file in the folder" do
      subject.create_environment_folder.create_version_folder.create_current_symlink_folder
      expect{subject.test_files}.to raise_error
    end

    it "creates a symlink file from tested files" do
      subject.create_deploy_structure
      ## Faking the config folder that should come with the repository
      FileUtils.mkdir_p "#{config.env_time_folder}/config"
      `echo "DB data...." >> #{config.deploy_folder}/config/#{config.environment}/databases.yml`
      subject.create_symlinked_files.should satisfy do |deployer|
        File.symlink?( "#{config.env_time_folder}/config/databases.yml")
      end
    end
  end

  context 'Execution' do
    it "should execute the after run tasks" do
      subject.create_deploy_structure
      FileUtils.mkdir_p "#{config.env_time_folder}/config"
      `echo "DB data..." >> #{config.deploy_folder}/config/#{config.environment}/databases.yml`
      subject.after_deploy_run.should satisfy do |deployer|
        File.directory?("#{config.env_time_folder}/new_folder")
      end
    end

    it "should capture STDERR messages in a variable is command is not valid" do
      subject.create_deploy_structure
      subject.config.after['run'] = [ 'This is not a command' ]
      out = subject.after_deploy_run
      out.count.should == 1
      out[0][:stdout].should == ""
      out[0][:stderr].should_not == ""
    end

    it "should not capture STDERR messages in a variable if command is valid" do
      subject.create_deploy_structure
      subject.config.after['run'] = [ 'ls -lah' ]
      out = subject.after_deploy_run
      out.count.should == 1
      out[0][:stdout].should_not == ""
      out[0][:stderr].should == ""
    end
  end
end
