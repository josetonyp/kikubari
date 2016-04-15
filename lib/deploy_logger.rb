module Kikubari
  class Deploy
    class Logger

      def head(message)
        p "*" * 80
        p "* #{message}"
        p "*" * 80
        p ""
      end

      def run(message, folder = nil )
        print( message, "Executing: " )
        p "   in folder: #{folder} " unless folder.nil?
      end

      def error ( message )
        print( message, "Error:" )
      end

      def result ( message )
        print( message, "Out:" )
      end

      def info( message )
        print( message )
      end

      def print(message, status = "")
        p "[#{DateTime.now.strftime('%Y%m%d %H:%M:%S')}] #{status} #{message}"
      end

    end
  end
end
