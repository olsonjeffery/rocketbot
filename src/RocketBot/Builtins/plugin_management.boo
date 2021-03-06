﻿namespace RocketBot.Scripts

import System
import RocketBot.Core

plugin PluginManagement:
  name "plugin_management"
  version "0.1"
  author "pfox"
  desc "allows the enabling and disabling of plugins"
  
  docs plugins:
    """
syntax: !plugins
Displays a list of currently installed plugins and some information about them
    """
  
  docs enable:
    """
syntax: !enable <plugin_name>
enables the selected plugin. use !plugins for a list of all installed plugins and their enabled status. This command is only available to bot admins
    """
  
  docs disable:
    """
syntax: !disable <plugin_name>
disables the selected plugin. use !plugins for a list of all installed plugins and their enabled status. This command is only available to bot admins
    """
  
  bot_command plugins:
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
      disabledText = ("(DISABLED)" if plugin.IsEnabled else "")
      IrcConnection.SendPRIVMSG(message.Nick, plugin.Name + disabledText +" version "+plugin.Version+" by "+plugin.Author+" -- "+plugin.Description)
  
  bot_command enable:
    if not Utilities.IsUserBotAdmin(message.Nick):
      return 
    if displayDocs:
      IrcConnection.SendPRIVMSG(message.Nick, "'enable' syntax: enable <plugin_name>")
      return
    
    pluginName = message.Args
    result = PluginLoader.EnablePlugin(pluginName)
    if not result:
      IrcConnection.SendPRIVMSG(message.Nick, "plugin '"+pluginName+"' either doesn't exist or is already enabled!")
    else:
      IrcConnection.SendPRIVMSG(message.Nick, "plugin '"+pluginName+"' is now enabled!")
  
  bot_command disable:
    if not Utilities.IsUserBotAdmin(message.Nick):
      return 
    if displayDocs:
      IrcConnection.SendPRIVMSG(message.Nick, "'disable' syntax: enable <plugin_name>")
      return
    
    pluginName = message.Args
    result = PluginLoader.DisablePlugin(pluginName)
    if not result:
      IrcConnection.SendPRIVMSG(message.Nick, "plugin '"+pluginName+"' either doesn't exist or is already disabled!")
    else:
      IrcConnection.SendPRIVMSG(message.Nick, "plugin '"+pluginName+"' is now disabled!")