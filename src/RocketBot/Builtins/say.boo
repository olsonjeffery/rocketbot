namespace RocketBot.Scripts

import System
import System.Collections.Generic
import System.Text.RegularExpressions
import RocketBot.Core

plugin SayPlugin:
  name "say"
  version "0.1"
  author "pfox"
  desc "speak through the bot"
  
  docs say, speak:
    """
syntax: !say <#channel/nickname> <message> (or !speak)
Have the bot send 'message' to the location targetted by #channel/nickname. This command is only available to bot admins.
    """
  
  bot_command say, speak:
    if not Utilities.IsUserBotAdmin(message.Nick):
      IrcConnection.SendPRIVMSG(message.Nick, "Sorry, this command is only available to bot admins.")
      return
    arr = List[of string]()
    arr.Add(" ")
    all = List[of string](message.Args.Split(arr.ToArray(), StringSplitOptions.None))
    target = all[0]
    all.RemoveAt(0)
    msg = String.Join(" ", all.ToArray())
    IrcConnection.SendPRIVMSG(target, msg)
    IrcConnection.SendPRIVMSG(message.Nick, "Okay, I just said '"+msg+"' to '"+target+"'.")