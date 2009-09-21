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
    logMsg = LogMessage.NewestMessageFrom(message.Args)
    if logMsg is null:
      IrcConnection.SendPRIVMSG(message.Channel, "Sorry, I haven't seen "+message.Nick)
    else:
      IrcConnection.SendPRIVMSG(message.Channel, message.Nick + " was last seen on " + logMsg.CreateDate.ToShortDateString() + " " + logMsg.CreateDate.ToLongTimeString())