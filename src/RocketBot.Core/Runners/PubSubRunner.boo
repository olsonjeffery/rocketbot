namespace RocketBot.Core

import System
import System.Collections.Generic

public static class PubSubRunner:
  
  _commandsByMessageName as Dictionary[of string, List[of RawMSGCommand]]
  _pluginIdsByCommand as Dictionary[of RawMSGCommand, Guid]
  
  public def Initialize():
    _commandsByMessageName = Dictionary[of string, List[of RawMSGCommand]]()
    _pluginIdsByCommand = Dictionary[of RawMSGCommand, Guid]()
  
  public def RegisterCommand(commandInfo as CommandWrapper):
    _commandsByMessageName[commandInfo.MessageName] = List of RawMSGCommand() if not _commandsByMessageName.ContainsKey(commandInfo.MessageName)
    _commandsByMessageName[commandInfo.MessageName].Add(commandInfo.RawMSGMethod)
    
    _pluginIdsByCommand[commandInfo.RawMSGMethod] = commandInfo.PluginId
  
  public def RaiseCommand(messageName as string, ircMessage as IncomingMessage):
    if not _commandsByMessageName.ContainsKey(messageName):
      raise "there is no handler registered for a message named '"+messageName+"'"
    for item as RawMSGCommand in _commandsByMessageName[messageName]:
      ActionQueue.EnqueueItem(ActionItem(ircMessage, item)) if PluginLoader.Plugins[_pluginIdsByCommand[item]].IsEnabled