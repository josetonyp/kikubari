require 'pry'
require 'kikubari'

root_folder = Pathname.new(File.expand_path(__dir__))

module ProjectHelper
  def clear_target_project
    FileUtils.mkdir_p(RSpec.configuration.target_folder) unless Dir.exist?(RSpec.configuration.target_folder)
    FileUtils.rm_rf(Dir.glob("#{RSpec.configuration.target_folder}/*"))
  end
end

RSpec.configure do |c|
  c.add_setting :src_folder
  c.add_setting :target_folder
  c.add_setting :deploy_files

  c.src_folder = root_folder.join('project')
  c.target_folder = root_folder.join('project_dfolder')
  c.deploy_files = root_folder.join('deploy_files')
  c.include ProjectHelper

end
