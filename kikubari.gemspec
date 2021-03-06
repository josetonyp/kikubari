Gem::Specification.new do |s|
  s.name = "kikubari"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jose Antonio Pio Gil"]
  s.date = "2016-04-15"
  s.description = " Naive multiframework deployer for handle server deployments with some care about the code replacement. Also an experimental project."
  s.email = "josetonyp@latizana.com"
  s.executables = ["kikubari"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/kikubari",
    "kikubari.gemspec",
    "lib/configuration/deploy_configuration.rb",
    "lib/deploy_dir.rb",
    "lib/deploy_logger.rb",
    "lib/deployer/deployer.rb",
    "lib/deployer/deployer_git.rb",
    "lib/deployer/deployer_git_wordpress.rb",
    "lib/kikubari.rb",
    "spec/deploy_files/databases.yml",
    "spec/deploy_files/deploy.yml",
    "spec/deploy_files/deploy_git.yml",
    "spec/deploy_files/deploy_git_test_file.yml",
    "spec/deploy_files/deploy_symlink.yml",
    "spec/deploy_files/empty.yml",
    "spec/deploy_files/one_file_test.yml",
    "spec/deploy_files/one_folder.yml",
    "spec/lib/deploy_spec.rb",
    "spec/lib/deployers/git.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "https://github.com/josetonyp/kikubari"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.5.1"
  s.summary = "Naive multiframework deploy system"

  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency('pry', '~> 0.10')
  s.add_development_dependency('rspec', '~> 3.4')
  s.add_development_dependency('rake', '~> 11.1')

  s.add_dependency('git', '~> 1.3')
end

