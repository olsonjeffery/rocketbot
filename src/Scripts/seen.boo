namespace RocketBot.Scripts

import System
import RocketBot.Core

plugin SeenPlugin:
  name "seen"
  version "1"
  author "pfox"
  desc "shows when the person requested was last seen in the requesting user's channel"
  
  setup:
    pass
 
  bot_command seen, whereis:
    Utilities.DebugOutput("should seen "+message.Args)
