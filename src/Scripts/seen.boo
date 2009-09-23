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
      IrcConnection.SendPRIVMSG(message.Channel, "Sorry, I haven't seen "+message.Args)
    else:
      nowDate = DateTime.Now
      ts = nowDate - logMsg.CreateDate
      
      timespanString = ""
      timespanString += ts.Days + " day, " if ts.Days == 1
      timespanString += ts.Days + " days, " if ts.Days > 1
      timespanString += ts.Hours + " hour, " if ts.Hours == 1
      timespanString += ts.Hours + " hours, " if ts.Hours > 1
      timespanString += ts.Minutes + " minute, " if ts.Minutes == 1
      timespanString += ts.Minutes + " minutes, " if ts.Minutes > 1
      timespanString += ts.Seconds + " second" if ts.Seconds == 1
      timespanString += ts.Seconds + " seconds" if ts.Seconds > 1
      IrcConnection.SendPRIVMSG(message.Channel, message.Args + " was last seen "+ timespanString +" ago (" + logMsg.CreateDate.ToShortDateString() + " " + logMsg.CreateDate.ToLongTimeString() + "), saying: '" + logMsg.Message + "'")