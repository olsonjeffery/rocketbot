namespace RocketBot.Scripts

import System
import RocketBot.Core

plugin LaeveCommand:
  name "leave"
  version "0.1"
  author "pfox"
  desc "tells the bot to shutdown. available only to bot admins"
  bot_command "^(?<command>(quit|exit|bye|leave|seeya))(?<args>.*)$", leave, bye, seeya, quit, exit:
    if not Utilities.IsUserBotAdmin(message.Nick):
      return 
    
    // if this is true, then instead of running the command, we just output
    // the documentation for this command to the requesting user via privmsg
    if displayDocs:
      // display syntax stuff here
      IrcConnection.SendPRIVMSG(message.Nick, 'Documentation for the ADMIN \'leave\' command:')
      IrcConnection.SendPRIVMSG(message.Nick, 'Synonyms: bye, seeya, quit, exit')
      IrcConnection.SendPRIVMSG(message.Nick, 'Syntax: leave')
      IrcConnection.SendPRIVMSG(message.Nick, 'Alternative Syntax: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Parameters: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'ADMIN COMMAND: Make the bot go away. Causes the program to end.')
      return 
    
    IrcConnection.GracefulExit()