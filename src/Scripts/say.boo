namespace RocketBot.Scripts

import System
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
    m = Regex("""^(?<target>[^\\s]+) (?<message>.+)$""").Match(message.Args)
    if m.Success:
      target = m.Groups['target'].Value.Trim()
      msg = m.Groups['target'].Value.Trim()
      IrcConnection.SendPRIVMSG(target, msg)
      IrcConnection.SendPRIVMSG(message.Nick, "Okay, I just said '"+msg+"' to '"+target+"'.")
    else:
      IrcConnection.SendPRIVMSG(message.Nick, "Sorry, I'm unable to craft a message to send to someone from the input '"+message.Args+"'. See the docs for more info.")
