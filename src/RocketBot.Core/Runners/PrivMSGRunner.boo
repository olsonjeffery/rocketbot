namespace RocketBot.Core

import System
import System.Collections.Generic
import System.Text.RegularExpressions

public class PrivMSGRunner:
  private static _commandSyntaxDict as Dictionary[of string, Regex] = Dictionary[of string, Regex]()
  
  static _pluginIds as Dictionary[of string, Guid]
  private static _lexicon as Dictionary[of string, PrivMSGCommand]
  public static Lexicon as Dictionary[of string, PrivMSGCommand]:
    get:
      return _lexicon
  
  public static def RegisterCommand(commandInfo as CommandWrapper):
    
    // first of all create _lexicon entries for each entry
    // in commandNames..
    for commandName as string in commandInfo.Names:
      _lexicon.Add(commandName, commandInfo.PrivMSGMethod)
      if _pluginIds.ContainsKey(commandName):
        raise "there is already a registered command named '"+commandName+"'"
      _pluginIds.Add(commandName, commandInfo.PluginId)
    
    // then we register the regex with the Names entry
    // in index 0
    _commandSyntaxDict.Add(commandInfo.Names[0], commandInfo.SyntaxPattern)
    
  public static def Initialize():
    
    _pluginIds = Dictionary[of string, Guid]()
    // the dictionary that contains the string/value pairs pointing to
    _lexicon = Dictionary[of string, PrivMSGCommand]()
    // set up the command syntax dict, which does all of out syntax parsing for
    // us...
    _commandSyntaxDict = Dictionary[of string, Regex]()
    
  public static def ExecuteCommand(message as IncomingMessage):
    
    try:
      ExecuteCommand(message.Command, message)
    except e as Exception:
      
      // blah!
      Console.WriteLine(((Utilities.TimeStamp() + 'Whoops! Exception in ExecuteCommand(IncomingMessage): ') + e.ToString()))
    
  public static def ExecuteCommand(commandTemp as string, message as IncomingMessage):
    if not PluginLoader.Plugins[_pluginIds[commandTemp]].IsEnabled:
      IrcConnection.SendPRIVMSG(message.Nick, "Sorry, the '"+commandTemp+"' command is currently disabled.")
    else:
      try:
        command = cast(PrivMSGCommand, _lexicon[commandTemp])
        
        ActionQueue.EnqueueItem(ActionItem(message, command))
      except e as Exception:
        Console.WriteLine(((Utilities.TimeStamp() + 'Whoops! Exception in ExecuteCommand(string, IncomingMessage): ') + e.ToString()))
  
  public static def DoesCommandExist(key as string) as bool:
    return Lexicon.ContainsKey(key)
  
  public static def ParseCommand(message as IncomingMessage):
    // in case the command get's wiped out when passed as an 'out',
    // we have it here
    commandTemp as string = message.Command
    
    // check if command exists
    if not PrivMSGRunner.DoesCommandExist(message.Command):
      // bad command name
      if not bool.Parse(BotConfig.GetParameter('SupressCommandNotFoundMessage')):
        IrcConnection.SendPRIVMSG(message.Nick, (('The \'' + message.Command) + '\' command does not exist, sorry.')) 
      return 
      
    // check if the message is properly formed...?
    
    Utilities.DebugOutput(('Parse Command attempted message: ' + message.Message))
    
    // if this returns false, then we're going to try iterating through the
    // entire CommandSyntaxDict, in the event that this command is a "synonym"
    if not PrivMSGRunner.ParseSyntaxByCommand(message.Command, message.Message, message.Command, message.Args):
      
      PrivMSGRunner.ParseSyntax(message.Message, message.Command, message.Args)
      
    if message.Command == '.':
      Utilities.DebugOutput('Bad natural language attempt.')
      IrcConnection.SendPRIVMSG(message.Nick, (((('Bad syntax for the \'' + commandTemp) + '\' command. Use \'!help ') + commandTemp) + '\' to get information on the proper syntax for this command.'))
    else:
      PrivMSGRunner.ExecuteCommand(message)
    
  public static def ParseSyntax(message as string, ref command as string, ref args as string) as bool:
    
    m as Match
    command = '.'
    args = '.'
    
    Utilities.DebugOutput((('Target message for parsing: \'' + message) + '\''))
    
    for regexVal as Regex in _commandSyntaxDict.Values:
      
      m = regexVal.Match(message)
      if m.Success:
        
        command = m.Groups['command'].Value
        args = m.Groups['args'].Value.Trim()
        return true
        
      
    
    Utilities.DebugOutput((('Unable to extract syntax parse info from: \'' + message) + '\''))
    return false
    
  public static def ParseSyntaxByCommand(commandName as string, message as string, ref command as string, ref args as string) as bool:
    
    m as Match
    command = '.'
    args = '.'
    
    if not PrivMSGRunner.DoesCommandExist(commandName):
      return false
    else:
      
      // if a syntax entry for our command does not exist, return false.
      if not _commandSyntaxDict.ContainsKey(commandName):
        Utilities.DebugOutput((('No syntax entry for \'' + commandName) + '\' command.'))
        return false
        
      
      m = _commandSyntaxDict[commandName].Match(message)
      if m.Success:
        
        command = m.Groups['command'].Value
        args = m.Groups['args'].Value.Trim()
        return true
        
    
    return false