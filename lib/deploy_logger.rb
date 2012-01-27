module Kikubari
  
  class Deploy
    
    class Logger


        def head(message)
          p "****************************************************************************************************"
          p "* #{message}"
          p "****************************************************************************************************"
          p ""
        end
        
        def run(message, folder = nil )
          p "Executing: '#{message}' "
          p "   time #{DateTime.now}"
          p "   in folder: #{folder} " unless folder.nil?
        end
        
        def error ( message )
          p "Error: '#{message}' "
        end
        
        def result ( message )
          p "Out: '#{message}' "
        end
    
    end
  end
end