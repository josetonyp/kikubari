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
    it "creates a target version folder with a the current time stamp as name" do
      expect(subject.create_release_folder).to satisfy do |deployer|
        File.directory?(deployer.config.env_time_folder)
      end
    end

    it "createa a symlink 'current' to the actual target version folder" do
      expect(subject.create_release_folder.create_current_symlink_folder).to satisfy do |deployer|
        File.symlink?(deployer.config.current_deploy_folder)
      end
    end

    # Giving a folder structure like:
    # From file: spec/deploy_files/deploy_symlink.yml
    #
    #  folder_structure:
    #    cache: 'cache/#{environment}'
    #    config: 'config/#{environment}'
    #    blank: ''
    #
    # Example:
    # project:
    #   cache
    #   config
    #   releases
    #     [version_folder]
    #       cache: Symlink to cache
    #       config: Symlink to config
    #     current: Symlink to [version_folder]
    #
    it "creates the cache and condig folder inside" do
      subject.tap do |deployer|
        deployer.create_release_folder
        deployer.create_structure
        deployer.create_sylinked_folders

        expect(File.symlink?("#{deployer.config.env_time_folder}/cache")).to be_truthy
        expect(File.symlink?("#{deployer.config.env_time_folder}/config")).to be_truthy
      end
    end

    it 'does not create a symlink when target folder is blank is blank' do
      subject.tap do |deployer|
        deployer.create_release_folder
        deployer.create_structure
        deployer.create_sylinked_folders

        expect(File.symlink?("#{deployer.config.env_time_folder}/blank")).to be_falsy
      end
    end
  end

  context 'File linking' do
    it "verifies a file in the folder and raise an error" do
      subject.tap do |deployer|
        deployer.create_release_folder
        deployer.create_current_symlink_folder
        expect{deployer.test_files}.to raise_error ArgumentError
      end
    end

    it "verifies a file in the folder" do
      subject.tap do |deployer|
        deployer.create_release_folder
        deployer.create_structure
        deployer.create_current_symlink_folder
        `echo "DB data...." >> #{deployer.config.deploy_folder}/config/databases.yml`

        expect{deployer.test_files}.to_not raise_error ArgumentError
      end
    end

    it "creates a symlink file from tested files" do
      subject.tap do |deployer|
        deployer.create_release_folder
        deployer.create_structure
        deployer.create_current_symlink_folder
        `echo "DB data...." >> #{deployer.config.deploy_folder}/config/databases.yml`

        deployer.create_symlinked_files
        expect(File.symlink?( "#{config.env_time_folder}/databases.yml")).to be_truthy
      end
    end
  end

  context 'Execution' do
    it "should execute the after run tasks" do
      subject.tap do |deployer|
        deployer.create_release_folder
        deployer.create_structure
        deployer.create_current_symlink_folder
        deployer.after_deploy_run

        expect(File.directory?("#{config.env_time_folder}/new_folder")).to be_truthy
      end
    end

    it "should capture STDERR messages in a variable is command is not valid" do
      subject.tap do |deployer|
        deployer.create_release_folder
        deployer.create_structure
        deployer.create_current_symlink_folder

        deployer.config.after.run = [ 'This is not a command' ]
        deployer.after_deploy_run.tap do |out|
          expect(out.count).to eq(1)
          expect(out[0][:stdout]).to eq("")
          expect(out[0][:stderr]).to_not eq("")
        end
      end
    end

    it "should not capture STDERR messages in a variable if command is valid" do
      subject.tap do |deployer|
        deployer.create_release_folder
        deployer.create_structure
        deployer.create_current_symlink_folder

        deployer.config.after.run = [ 'ls -lah' ]
        deployer.after_deploy_run.tap do |out|
          expect(out.count).to eq(1)
          expect(out[0][:stdout]).to_not eq("")
          expect(out[0][:stderr]).to eq("")
        end
      end
    end
  end
end
