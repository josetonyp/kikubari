require 'spec_helper'

describe Kikubari::Deploy::GitDeployer do
  let(:git_config) do
    Kikubari::Deploy::Configuration.new(
      "#{RSpec.configuration.deploy_files}/deploy_git.yml",
      deploy_folder: RSpec.configuration.target_folder,
      debug: false,
      dry_run: false,
      environment: 'production',
      rollback: false)
  end

  let(:deployer) { Kikubari::Deploy::GitDeployer.new(git_config) }

  before :all do
    clear_target_project
  end

  it "clones the repository in the version folder" do
    deployer.create_deploy_structure
    deployer.deploy
    expect(Dir.glob("#{deployer.config.env_time_folder}/*").count).to be > 0
  end

  it "removes the .git folder after cloning" do
    deployer.create_deploy_structure
    deployer.deploy
    expect(Dir.exist?("#{deployer.config.env_time_folder}/.git")).to be_falsy
    binding.pry
  end
end
