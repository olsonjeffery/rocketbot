namespace RocketBot.Core

import System
import System.Net
import System.IO
import System.Collections.Generic
import System.Text
import System.Text.RegularExpressions

public class PrivMSGRunner:

  
  private static _commandSyntaxDict as Dictionary[of string, Regex] = Dictionary[of string, Regex]()

  private def constructor():
    pass
    // empty ctor

  
  private static _lexicon as Dictionary[of string, PrivMSGCommand]

  
  
  public static def RegisterCommand(commandInfo as CommandWrapper):
    
    // first of all create _lexicon entries for each entry
    // in commandNames..
    for commandName as string in commandInfo.Names:
      _lexicon.Add(commandName, commandInfo.PrivMSGMethod)
    
    // then we register the regex with the Names entry
    // in index 0
    _commandSyntaxDict.Add(commandInfo.Names[0], commandInfo.SyntaxPattern)
    
    

  
  public static def Initialize():
    
    // the dictionary that contains the string/value pairs pointing to
    _lexicon = Dictionary[of string, PrivMSGCommand]()
    // set up the command syntax dict, which does all of out syntax parsing for
    // us...
    _commandSyntaxDict = Dictionary[of string, Regex]()
        
    // version
    _lexicon.Add('version', version_Command)
    _commandSyntaxDict.Add('version', Regex('^(?<command>version)(?<args>.*)$'))
    
    // help command
    _lexicon.Add('help', help_Command)
    _commandSyntaxDict.Add('help', Regex('^(?<command>help)(?<args>.*)$'))
        
    // leave and it's synonyms -- naturalized
    /*_lexicon.Add('leave', leave_Command)
    _lexicon.Add('bye', leave_Command)
    _lexicon.Add('seeya', leave_Command)
    _lexicon.Add('quit', leave_Command)
    _lexicon.Add('exit', leave_Command)
    _commandSyntaxDict.Add('leave', Regex('^(?<command>(quit|exit|bye|leave|seeya))(?<args>.*)$'))    */

  
  #region ExecuteCommand Methods
  
  public static def ExecuteCommand(message as IncomingMessage):
    
    try:
      ExecuteCommand(message.Command, message)
    except e as Exception:
      
      // blah!
      Console.WriteLine(((Utilities.TimeStamp() + 'Whoops! Exception in ExecuteCommand(IncomingMessage): ') + e.ToString()))
    
    

  
  public static def ExecuteCommand(commandTemp as string, message as IncomingMessage):
    
    try:
      command = cast(PrivMSGCommand, _lexicon[commandTemp])
      
      ActionQueue.EnqueueItem(ActionItem(message, command))
    except e as Exception:
      
      // blah!
      Console.WriteLine(((Utilities.TimeStamp() + 'Whoops! Exception in ExecuteCommand(string, IncomingMessage): ') + e.ToString()))
    
    

  
  #endregion
  
  
  public static def ParseCommand(message as IncomingMessage):
    
    
    
    // in case the command get's wiped out when passed as an 'out',
    // we have it here
    commandTemp as string = message.Command
    
    // check if command exists
    if not PrivMSGRunner.DoesCommandExist(message.Command):
      
      // bad command name
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
    
    
    

  
  
  
  
  
  #region Syntax Parsing Methods
  
  public static def ParseSyntax(message as string, ref command as string, ref args as string) as bool:
    
    m as Match
    command = '.'
    args = '.'
    
    Utilities.DebugOutput((('Target message for parsing: \'' + message) + '\''))
    
    for regexVal as Regex in _commandSyntaxDict.Values:
      
      m = regexVal.Match(message)
      if m.Success:
        
        command = m.Groups['command'].Value
        args = m.Groups['args'].Value
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
        args = m.Groups['args'].Value
        return true
        
    
    return false
    

  
  public static def DoesCommandExist(key as string) as bool:
    
    return _lexicon.ContainsKey(key)
    

  
  #endregion
  
  #region Lexical Methods
  
  #region help_Command()
  private static def help_Command(message as IncomingMessage, displayDocs as bool):
    // if this is true, then instead of running the command, we just output
    // the documentation for this command to the requesting user via privmsg
    if displayDocs:
      // display syntax stuff here
      IrcConnection.SendPRIVMSG(message.Nick, 'Documentation for the \'help\' command:')
      IrcConnection.SendPRIVMSG(message.Nick, 'Syntax: help <command>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Synonyms: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Alternative Syntax: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Parameters: command: the bot command for which you would like further help.')
      IrcConnection.SendPRIVMSG(message.Nick, 'Purpose: Provides the requesting user with documentation on the use and purpose of a given bot command.')
      
      return 
    
    args as string = message.Args.Trim()
    
    // check if this was executed with zero args.. if so then let's display
    // a list of commands that we can provide help for...
    if args == '':
      
      commandsString = ''
      
      keys as List[of string] = List[of string](_lexicon.Keys)
      keys.Sort()
      
      for key as string in keys:
        
        commandsString += (key + ', ')
        
      // chomp off the last two characters
      commandsString = commandsString.Remove((commandsString.Length - 2))
      
      IrcConnection.SendPRIVMSG(message.Nick, 'I have help documentation for the following commands:')
      IrcConnection.SendPRIVMSG(message.Nick, commandsString)
      return 
    
    // check and see if the requested command exists: if it does, then
    if not DoesCommandExist(args):
      
      IrcConnection.SendPRIVMSG(message.Nick, (('Sorry, the \'' + args) + '\' command does not exist.'))
      return 
      
    
    // since we're here, that means the command DOES EXIST.. so we'll
    // just make message.Command = message.Args .. and call ExecuteCommand()
    // again, but this time with the displayDocs bool set to true
    message.Command = args
    message.DisplayDocs = true
    ExecuteCommand(message)
    
    

  #endregion
  
  #region template_Command()
  private static def template_Command(message as IncomingMessage, displayDocs as bool):
    // if this is true, then instead of running the command, we just output
    // the documentation for this command to the requesting user via privmsg
    if displayDocs:
      // display syntax stuff here
      IrcConnection.SendPRIVMSG(message.Nick, 'Documentation for the \'template\' command:')
      IrcConnection.SendPRIVMSG(message.Nick, 'Synonyms: List of synonyms here.')
      IrcConnection.SendPRIVMSG(message.Nick, 'Syntax: template <arguments1> <arguments2>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Alternative Syntax: template for <arguments1> and <arguments2>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Parameters: arguments1: First arguoment description. arguements2: Second argument description')
      IrcConnection.SendPRIVMSG(message.Nick, 'Purpose: Brief overview of the utility of this command.')
      return 
    
    // template stuff goes here
    

  #endregion

  #region translate_Command() DISABLED
  private static def translate_Command(message as IncomingMessage, displayDocs as bool):
    
    if displayDocs:
      // display syntax stuff here
      IrcConnection.SendPRIVMSG(message.Nick, 'Documentation for \'template\' command:')
      IrcConnection.SendPRIVMSG(message.Nick, 'Syntax: template <arguments1> <arguments2>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Alternative Syntax: template for <arguments1> and <arguments2>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Parameters: arguments1: First arguoment description. arguements2: Second argument description')
      IrcConnection.SendPRIVMSG(message.Nick, 'Purpose: Brief overview of the utility of this command.')
      
      return 
    
    if not Utilities.IsUserBotAdmin(message.Nick):
      return 
    
    /*
            TranslateLanguage.Translate translate = new TranslateLanguage.Translate();
            string translatedText = translate.TranslateLanguage(TranslateLanguage.Language.English, TranslateLanguage.Language.Spanich, message.Args);
            Formatting.WriteToChannel(message.Channel, translatedText);
            */
    
    
    
    translate = TranslateService()
    translatedText as string = translate.Translate(Language.EnglishTOSpanish, message.Args.Trim())
    IrcConnection.SendPRIVMSG(message.Channel, translatedText)
    
    

  #endregion
  
  #region version_Command()
  private static def version_Command(message as IncomingMessage, displayDocs as bool):
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
    IrcConnection.SendPRIVMSG(message.Channel, (((('I am running predibot version ' + BotConfig.GetParameter('Version')) + ', released on ') + BotConfig.GetParameter('VersionDate')) + '.'))

  #endregion

  #endregion
  

