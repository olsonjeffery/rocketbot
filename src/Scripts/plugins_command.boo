namespace RocketBot.Scripts

import System
import RocketBot.Core
import System.Collections.Generic

plugin PluginInfoPlugin:
  name "plugins"
  desc "provides info about plugins"
  version "0.1"
  author "pfox"
  bot_command '^(?<command>plugins)(?<args>.*)$', plugins:
    
    if displayDocs:
      IrcConnection.SendPRIVMSG(message.Nick, 'Documentation for the \'plugins\' command:')
      IrcConnection.SendPRIVMSG(message.Nick, 'Synonyms: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Syntax: plugins')
      IrcConnection.SendPRIVMSG(message.Nick, 'Alternative Syntax: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Parameters: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Purpose: Provides info on the bot\'s loaded plugins')
      return 
    
    plugins = PluginLoader.Plugins.Values
    
    IrcConnection.SendPRIVMSG(message.Nick, "Here are the plugins that are loaded into this bot:")
    for plugin in plugins:
      IrcConnection.SendPRIVMSG(message.Nick, plugin.Name +" version "+plugin.Version+" by "+plugin.Author+" -- "+plugin.Description)