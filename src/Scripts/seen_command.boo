namespace RocketBot.Scripts

import System
import RocketBot.Core

plugin SeenPlugin:
  name "seen"
  version "1"
  author "pfox"
  desc "shows when the person requested was last seen in the requesting user's channel"
  
  setup:
    if not Database.DoesTableExist('ChannelLog'):
      raise "the seen plugin cannot work without the logging plugin configured and running. If this is the first time running the bot, remove the seen_command.boo script and run again so that the logging plugin has a change to get setup, re-introduce the seen_command.boo script and run the bot again."
  
  bot_command seen, whereis:
    Utilities.DebugOutput("should seen "+message.Args)