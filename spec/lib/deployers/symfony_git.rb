require File.expand_path( File.join( File.dirname(__FILE__), '..', '..', 'spec_helper.rb' ) ).to_s

describe Kikubari::Deploy::SymfonyGitDeployer do
  
  before :each do 
    @folder = "test/project_dfolder"
    @df_folder = "test/deploy_files"
    `rm -fR #{@folder}/*`
  end
  
  after :all do
    `rm -fR #{@folder}/*`
  end
  
  it "should clone the repository in the version folder" do
    @config = Kikubari::Deploy::Configuration.new( "#{@df_folder}/deploy_git.yml", :deploy_folder => @folder, :debug => false, :dry_run => false , :environment => "production", :rollback => false )
    @deployer = Kikubari::Deploy::GitDeployer.new(@config)
    @deployer.create_deploy_structure.deploy.should satisfy { |deployer| File.directory?( "#{deployer.config.env_time_folder}/.git" ) }
  end
  
  it "should create an symlinked file" do
    @config = Kikubari::Deploy::Configuration.new( "#{@df_folder}/deploy_git_test_file.yml", :deploy_folder => @folder, :debug => false, :dry_run => false , :environment => "production", :rollback => false )
    @deployer = Kikubari::Deploy::GitDeployer.new(@config)
    @deployer.create_deploy_structure
      `echo "hola" >> #{@folder}/log/#{@config.environment}/test.yml`
    @deployer.deploy.should satisfy { |deployer| File.readable?( "#{deployer.config.env_time_folder}/test/test.yml" ) }
  end

end