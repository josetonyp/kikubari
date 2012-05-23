# Deploy strategy for Git deployments
# Repository:: Git
#
# Author::    Jose A Pio  (mailto:josetonyp@gmail.com)
# Copyright:: Copyright (c) 2011
# License::   Distributes under the same terms as Ruby

module Kikubari
  class Deploy
    class GitDeployer < Deployer

      ##
      # deploys a git repository to given folder
      #
      def do_deploy
        branch = @config.config["branch"] || "master"
        %x(git clone #{@config.config["origin"]} -b #{branch} #{@config.env_time_folder} )
      end

    end

  end

end
