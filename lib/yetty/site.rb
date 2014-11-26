require 'yetty'

module Yetty
  class Site < Yetty::Command

    autoload :App, 'yetty/site/app'

    # Start the web UI
    #
    # @return true
    def execute!
      if(opts[:port])
        App.port = opts[:port]
      end
      if(opts[:bind])
        App.bind = opts[:bind]
      end
      App.server = options.fetch(:server, 'webrick')
      App.run!
    end

  end
end
