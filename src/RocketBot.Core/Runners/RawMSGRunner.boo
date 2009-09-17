namespace RocketBot.Core

import System
import System.Collections.Generic
import System.Text.RegularExpressions

public static class RawMSGRunner:

  
  private _lexicon as Dictionary[of string, RawMSGCommand]

  private _commandSyntaxDict as Dictionary[of string, Regex]
  
  private _pluginIds as Dictionary[of string, Guid]
  
  public def Initialize():
    // the dictionary that contains the string/value pairs pointing to
    _lexicon = Dictionary[of string, RawMSGCommand]()
    // set up the command syntax dict, which does all of out syntax parsing for
    // us...
    _commandSyntaxDict = Dictionary[of string, Regex]()
    _pluginIds = Dictionary[of string, Guid]()

  
  public def RegisterCommand(commandInfo as CommandWrapper):
    _pluginIds.Add(commandInfo.Names[0], commandInfo.PluginId)
    _lexicon.Add(commandInfo.Names[0], commandInfo.RawMSGMethod)
    _commandSyntaxDict.Add(commandInfo.Names[0], commandInfo.SyntaxPattern)
    

  
  #region ExecuteCommands
  
  public def ExecuteCommand(commandTemp as string, message as IncomingMessage):
    
    try:
      command = cast(RawMSGCommand, _lexicon[commandTemp])
      
      ActionQueue.EnqueueItem(ActionItem(message, command))
    except e as Exception:
      
      // blah!
      Console.WriteLine(((Utilities.TimeStamp() + 'Whoops! Exception in ExecuteCommand(string, IncomingMessage): ') + e.ToString()))
    
    

  
  public def ParseMessage(message as IncomingMessage):
    
    for key as string in _lexicon.Keys:
      if PluginLoader.Plugins[_pluginIds[key]].IsEnabled:
        m as Match = _commandSyntaxDict[key].Match(message.RawMessage)
        if m.Success:
          ExecuteCommand(key, message)
    
  
  #endregion
  

