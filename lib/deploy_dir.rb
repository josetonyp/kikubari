# This class extends Dir to add Deploy ad hoc feature for dealing with deploy folders
#
# Could be simply extend Dir class with extra functions but this class meant to be a Deploy System Directory class handler
# Author::    Jose A Pio  (mailto:josetonyp@gmail.com)
# Copyright:: Copyright (c) 2011 
# License::   Distributes under the same terms as Ruby

class DeployDir < Dir

  # Rotate old folders and reduce it number by the limit
  # == Params:
  # [+folder+] <b>String</b> A valid folder for deploys
  # [+limit+] <b>Integer</b> Limit the folders left in deploy folder 
  def self.rotate_folders(folder , limit)
    
    raise( ArgumentError, "Invalid directory #{ folder }") unless File.directory? folder
    limit = Integer(limit)
    
    list = Dir["#{folder}/*"]
    folders = list.select {|v| v =~ /\d+?/ }
    was = folders.length
    FileUtils.rm_f folders.reverse.slice( limit ,  folders.length  ) if folders.length > limit
    return was - limit 
  end 
    
  
end