# Bridge Class to link a deployer with it's deploy strategies.
# Framewokr:: Symfony 1.2 - 1.4
# Repository:: Git
#
# Could be simply extend Dir class with extra functions but this class meant to be a Deploy System Directory class handler
# Author::    Jose A Pio  (mailto:josetonyp@gmail.com)
# Copyright:: Copyright (c) 2011 
# License::   Distributes under the same terms as Ruby
module Kikubari
  class Deploy
    class SymfonyGitDeployer < GitDeployer

    end
  end
end
