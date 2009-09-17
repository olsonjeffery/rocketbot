namespace RocketBot.Scripts

import System
import RocketBot.Core

plugin VersionPlugin:
  name "version"
  version "0.1"
  desc "provides version information for the bot"
  author "pfox"
  bot_command '^(?<command>version)(?<args>.*)$', version:
    // if this is true, then instead of running the command, we just output
    // the documentation for this command to the requesting user via privmsg
    if displayDocs:
      // display syntax stuff here
      IrcConnection.SendPRIVMSG(message.Nick, 'Documentation for the \'version\' command:')
      IrcConnection.SendPRIVMSG(message.Nick, 'Synonyms: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Syntax: version')
      IrcConnection.SendPRIVMSG(message.Nick, 'Alternative Syntax: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Parameters: arguments1: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Purpose: Provides version information on the bot.')
      return 
    
    // print version info from config file
    IrcConnection.SendPRIVMSG(message.Channel, (((('I am running rocketbot version ' + BotConfig.GetParameter('Version')) + ', released on ') + BotConfig.GetParameter('VersionDate')) + '.'))