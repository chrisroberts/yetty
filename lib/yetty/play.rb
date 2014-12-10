require 'yetty'
require 'shelr'

module Yetty
  class Player < Shelr::Player
  end
end

module Yetty
  # Play command class
  class Play < Command

    # Invoke shelr record
    def execute!
      if(arguments.first.start_with?('http'))
        Yetty::Player.play_remote(arguments.first)
      else
        Yetty::Player.play_dump(arguments.first)
      end
    end

  end
end
