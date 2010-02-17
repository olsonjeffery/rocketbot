namespace RocketBot.Scripts

import System
import RocketBot.Core

plugin VersionPlugin:
  name "version"
  version "0.1"
  desc "provides version information for the bot"
  author "pfox"
  
  docs version:
    """
Documentation for the \'version\' command:
Synonyms: none
Syntax: version
Alternative Syntax: none
Parameters: arguments1: none
Purpose: Provides version information on the bot.
    """
  
  bot_command '^(?<command>version)(?<args>.*)$', version:
    // print version info from config file
    IrcConnection.SendPRIVMSG(message.Channel, (((('I am running rocketbot version ' + BotConfig.GetParameter('Version')) + ', released on ') + BotConfig.GetParameter('VersionDate')) + '.'))