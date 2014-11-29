require 'yetty/version'

# TTY utility
module Yetty
  autoload :Command, 'yetty/command'
  autoload :Push, 'yetty/push'
  autoload :Record, 'yetty/record'
  autoload :Site, 'yetty/site'
  autoload :Ui, 'yetty/ui'
  autoload :User, 'yetty/user'
end

require 'miasma'
require 'miasma/utils/smash'
