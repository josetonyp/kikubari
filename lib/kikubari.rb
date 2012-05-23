module Kikubari

  class Deploy

    attr_accessor :config

    def initialize ( configuration  )
      @config = configuration
      return rollback if @config.rollback
      deploy
    end

    def deploy
      deployer = get_deployer( @config )
      deployer.create_deploy_structure.deploy
    end

    def rollback
      p "rollingback"
    end

    def change( version )
      p "changing to version #{version}"
    end

    private

    def get_deployer config
      deployer_class = config.get_deployer_class
      eval(deployer_class).new config
    end


  end

end