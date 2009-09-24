namespace RocketBot.Scripts

import System
import RocketBot.Core

plugin LaeveCommand:
  name "leave"
  version "0.1"
  author "pfox"
  desc "tells the bot to shutdown. available only to bot admins"
  
  docs leave, bye, seeya, quit, exit:
    """
Documentation for the ADMIN \'leave\' command:
Synonyms: bye, seeya, quit, exit
Syntax: leave
Alternative Syntax: none
Parameters: none
ADMIN COMMAND: Make the bot go away. Causes the program to end.
    """
  
  bot_command "^(?<command>(quit|exit|bye|leave|seeya))(?<args>.*)$", leave, bye, seeya, quit, exit:
    if not Utilities.IsUserBotAdmin(message.Nick):
      return     
    IrcConnection.GracefulExit()