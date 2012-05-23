require File.expand_path( File.join( File.dirname(__FILE__), '..', 'spec_helper.rb' ) ).to_s

describe Kikubari::Deploy::Deployer do

  before :each do
    @folder = "test/project_dfolder"
    @df_folder = "test/deploy_files"
    `rm -fR #{@folder}/*`

    @config = Kikubari::Deploy::Configuration.new( "#{@df_folder}/deploy_symlink.yml", :deploy_folder => @folder, :debug => false, :dry_run => false , :environment => "production", :rollback => false )
    @deployer = Kikubari::Deploy::Deployer.new(@config)

  end

  after :all do
    `rm -fR #{@folder}/*`
  end

  it "should create an environment folder" do
    @deployer.create_environment_folder.should satisfy{ |deployer| File.directory?(deployer.config.environment_folder) }
  end

  it "should create a deploy version folder" do
      @deployer.create_version_folder.should satisfy{ |deployer| File.directory?(deployer.config.env_time_folder) }
  end

  it "should create the symlink to current folder" do
      @deployer.create_version_folder.create_current_symlink_folder.should satisfy{ |deployer| File.symlink?(deployer.config.current_deploy_folder) }
  end

  it "sould create a folder in the folder structure" do
    @deployer.create_environment_folder.create_version_folder.create_current_symlink_folder
    @deployer.create_structure.should satisfy{ |deployer| File.directory?( "#{deployer.config.deploy_folder}/cache/#{@config.environment}") }
  end

  it "should create a Symlinked Strcuture folder" do
    @deployer.create_environment_folder.create_version_folder.create_current_symlink_folder
    @deployer.create_structure.create_sylinked_folders.should satisfy{ |deployer| File.symlink?( "#{deployer.config.env_time_folder}/cache") }
  end

  it "should not create the symlinked folder is folder already exist" do
    @deployer.create_environment_folder.create_version_folder.create_current_symlink_folder
    @deployer.create_structure
    FileUtils.mkdir_p "#{@config.env_time_folder}/cache"
    expect {
      @deployer.create_sylinked_folders
    }.should raise_error
  end

  it "should verify a file in the folder and raise an error" do
    @deployer.create_environment_folder.create_version_folder.create_current_symlink_folder
    expect{@deployer.test_files}.should raise_error
  end

  it "should verify a file in the folder" do
    @deployer.create_environment_folder.create_version_folder.create_current_symlink_folder
    expect{@deployer.test_files}.should raise_error
  end

  it "should create a symlink file from tested files" do
    @deployer.create_deploy_structure
    `mkdir -p #{@config.env_time_folder}/config` ## Faking the canfig folder that should come with the repository
    `echo "hola" >> #{@folder}/config/#{@config.environment}/databases.yml`
    @deployer.create_symlinked_files.should satisfy do |deployer|
      File.symlink?( "#{@config.env_time_folder}/config/databases.yml")
    end
  end

  it "should execute the after run tasks" do
    @deployer.create_deploy_structure
    `mkdir -p #{@config.env_time_folder}/config` ## Faking the canfig folder that should come with the repository
    `echo "hola" >> #{@folder}/config/#{@config.environment}/databases.yml`
    @deployer.after_deploy_run.should satisfy { |deployer| File.directory?("#{@config.env_time_folder}/new_folder") }
  end

  it "should capture STDERR messages in a variable is command is not valid" do
    @deployer.create_deploy_structure
    @deployer.config.after['run'] = [ 'This is not a command' ]
    out = @deployer.after_deploy_run
    out.count.should == 1
    out[0][:stdout].should == ""
    out[0][:stderr].should_not == ""
  end

  it "should not capture STDERR messages in a variable if command is valid" do
    @deployer.create_deploy_structure
    @deployer.config.after['run'] = [ 'ls -lah' ]
    out = @deployer.after_deploy_run
    out.count.should == 1
    out[0][:stdout].should_not == ""
    out[0][:stderr].should == ""
  end

end
