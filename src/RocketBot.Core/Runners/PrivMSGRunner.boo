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
    
    // list of commands/syntax and their delegates

    // hello command
    // moves to CoreCommands in Predibot project
    
    // search command
    _lexicon.Add('search', search_Command)
    _commandSyntaxDict.Add('search', Regex('^(?<command>search) (?<args>.*)$'))
    
    // weather
    _lexicon.Add('weather', weather_Command)
    // naturalized
    _commandSyntaxDict.Add('weather', Regex('(^(?<command>weather)\\s+(?<args>[0-9]{5})$|^(?<command>weather) for (?<args>[0-9]{5})$)'))
    
    // spell
    _lexicon.Add('spell', spell_Command)
    _commandSyntaxDict.Add('spell', Regex('^(?<command>spell) (?<args>.*)$'))
    
    
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
  
  #region idtoservices_Command() DISABLED
  private static def idtoservices_Command(message as IncomingMessage, displayDocs as bool):
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
    
    // this marks this method as an "admin only" method
    if not Utilities.IsUserBotAdmin(message.Nick):
      return 
    
    // template stuff goes here
    result as bool = IrcConnection.IsNickIdentifiedToServices(message.Args.Trim())
    
    IrcConnection.SendPRIVMSG(message.Channel, ((('User ' + message.Args.Trim()) + ' is identified to services: ') + result.ToString()))

  #endregion
  
  #region leave_Command()
  private static def leave_Command(message as IncomingMessage, displayDocs as bool):
    
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
    

  #endregion

  #region search_Command()
  private static def search_Command(message as IncomingMessage, displayDocs as bool):
    // search service provided compliments of live.com (yuck) because
    // yahoo and google are a bunch of pricks
    
    // if this is true, then instead of running the command, we just output
    // the documentation for this command to the requesting user via privmsg
    if displayDocs:
      // display syntax stuff here
      IrcConnection.SendPRIVMSG(message.Nick, 'Documentation for the \'search\' command:')
      IrcConnection.SendPRIVMSG(message.Nick, 'Synonyms: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Syntax: search <topic>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Alternative Syntax: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Parameters: topic: The word or series of words for which you\'d like information.')
      IrcConnection.SendPRIVMSG(message.Nick, 'Purpose: Conducts an MSN Live search on the topic provided, returning the name, URL and description of the top, most "relevent" result. We use MSN because Google no longer provides app keys to their SOAP-based web search service, so don\'t ask.')
      return 
    
    try:
      service as MSNSearch.MSNSearchService = MSNSearch.MSNSearchService()
      
      search as MSNSearch.SearchRequest = MSNSearch.SearchRequest()
      arraySize = 1
      source as (MSNSearch.SourceRequest) = array(MSNSearch.SourceRequest, arraySize)
      
      source[0] = MSNSearch.SourceRequest()
      source[0].Source = MSNSearch.SourceType.Web
      
      //search.AppID = AppID;
      search.AppID = BotConfig.GetParameter('SearchAppID')
      search.Query = message.Args.Trim()
      search.Requests = source
      search.CultureInfo = 'en-US'
      
      response as MSNSearch.SearchResponse
      response = service.Search(search)
      
      srcResponse as (MSNSearch.SourceResponse) = response.Responses
      for ctr in range(0, 1):
      
        
        srcResults as (MSNSearch.Result) = srcResponse[ctr].Results
        
        ctr2 = 0
        goto converterGeneratedName3
        while true:
          ctr += 1
          :converterGeneratedName3
          break  unless (ctr < 1)
          IrcConnection.SendPRIVMSG(message.Channel, ((srcResults[ctr2].Title.ToString() + ' -- ') + srcResults[ctr2].Url.ToString()))
          IrcConnection.SendPRIVMSG(message.Channel, ('Description: ' + srcResults[ctr2].Description.ToString()))
        
        
        if srcResults[0].Url.ToString() == '':
          IrcConnection.SendPRIVMSG(message.Channel, 'No result found.')
    
    
    
    except e as System.IndexOutOfRangeException:
      
      // poop!
      IrcConnection.SendPRIVMSG(message.Channel, 'No search result found.')
    
    

  #endregion
  
  
  
  
  
  #region spell_Command()
  private static def spell_Command(message as IncomingMessage, displayDocs as bool):
    // spelling, yay
    // http://spell.ockham.org/?word=origami&dictionary=master
    
    // if this is true, then instead of running the command, we just output
    // the documentation for this command to the requesting user via privmsg
    if displayDocs:
      // display syntax stuff here
      IrcConnection.SendPRIVMSG(message.Nick, 'Documentation for the \'spelling\' command:')
      IrcConnection.SendPRIVMSG(message.Nick, 'Synonyms: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Syntax: spell <word>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Alternative Syntax: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Parameters: word: The word you would like spelling advice on.')
      IrcConnection.SendPRIVMSG(message.Nick, 'Purpose: Attempt to find the correct spelling for the supplied word.')
      return 
    
    // let's make sure we only have one word
    oneWordPattern = Regex('^[^0-9]+$')
    
    // if there are numbers in the args, or more than one word
    // (ie contains whitespace) then lets put out the failure
    // message
    if not oneWordPattern.IsMatch(message.Args.Trim()):
      
      IrcConnection.SendPRIVMSG(message.Channel, 'The spell command only works with letters, I cannot offer spelling suggestions for numbers.')
      return 
    
    // ripped from the web summary command
    sb = StringBuilder()
    buf as (byte) = array(byte, 8192)
    resStream as Stream = Stream.Null
    
    try:
      
      Console.WriteLine((Utilities.TimeStamp() + 'loading table...'))
      request = cast(HttpWebRequest, WebRequest.Create((('http://spell.ockham.org/?word=' + message.Args.ToString().Trim()) + '&dictionary=master')))
      
      response = cast(HttpWebResponse, request.GetResponse())
      
      resStream = response.GetResponseStream()
      
      tempString as string = null
      count = 0
      
      while true:
        // fill the buffer with data
        count = resStream.Read(buf, 0, buf.Length)
        
        // make sure we read some data
        if count != 0:
          // translate from bytes to ASCII text
          tempString = Encoding.ASCII.GetString(buf, 0, count)
          
          // continue building the string
          //char[] trimChars = {'\n'};
          sb.Append(tempString)
        break  unless (count > 0)
      // any more data to read?
      Console.WriteLine((Utilities.TimeStamp() + 'before parse attempt'))
      
      xmlString as string = sb.ToString()
      
      spellingsOpen as (string) = ('<spellings>',)
      spellingsClose as (string) = ('</spellings>',)
      
      splitOne as (string) = xmlString.Split(spellingsOpen, StringSplitOptions.None)
      splitTwo as (string) = splitOne[1].Split(spellingsClose, StringSplitOptions.None)
      
      finalStr as string = splitTwo[0]
      finalStr = finalStr.Replace('\n', '')
      finalStr = finalStr.Replace('\t', '')
      
      //string[] spellingOpen = { @"<spelling>" };
      //string[] spellingClose = { @"</spelling>" };
      finalStr = finalStr.Replace('<spelling>', '')
      finalStr = finalStr.Replace('</spelling>', ', ')
      finalTwo as string = finalStr.Substring(0, (finalStr.Length - 2))
      
      commaSpace as (string) = (', ',)
      finalCheck as (string) = finalTwo.Split(commaSpace, StringSplitOptions.None)
      if finalCheck[0].ToString() == message.Args.Trim():
        
        IrcConnection.SendPRIVMSG(message.Channel, (message.Args.Trim() + ' appears to be spelled correctly.'))
        return 
      
      IrcConnection.SendPRIVMSG(message.Channel, (('Suggestions for ' + message.Args.Trim()) + ':'))
      IrcConnection.SendPRIVMSG(message.Channel, finalTwo)
    
    
    except e as Exception:
      
      Console.WriteLine(('Ruh roh! Exception: ' + e.ToString()))
      IrcConnection.SendPRIVMSG(message.Channel, 'It appears that spelling that word is a bit more than I can handle.')
    
    
    

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
  
  #region weather_Command()
  private static def weather_Command(message as IncomingMessage, displayDocs as bool):
    
    // if this is true, then instead of running the command, we just output
    // the documentation for this command to the requesting user via privmsg
    if displayDocs:
      // display syntax stuff here
      IrcConnection.SendPRIVMSG(message.Nick, 'Documentation for the \'weather\' command:')
      IrcConnection.SendPRIVMSG(message.Nick, 'Synonyms: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Syntax: weather <zip>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Alternative Syntax: weather for <zip>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Parameters: zip: a five digit numerical zip code')
      IrcConnection.SendPRIVMSG(message.Nick, 'Purpose: Provides current weather information for the supplied zip code.')
      return 
    
    
    // need to parse out the zip..
    // parse passed in zip to string
    
    // bring the methods under the "new" command parse regime?
    match as Match = Regex('(?<zip>[0-9]{5})').Match(message.Args.Trim())
    
    
    Utilities.DebugOutput(('Pre-parse ZIP: ' + message.Args))
    zip = ''
    if match.Success:
      
      zip = match.Groups['zip'].Value
    else:
      
      IrcConnection.SendPRIVMSG(message.Channel, 'Bad ZIP code format, use only five-letter zip codes to represent a location, please. Non-US people, you\'re out of luck.')
      return 
    
    
    // need to convert the zip to long/lat
    // http://www.zipinfo.com/cgi-local/zipsrch.exe?ll=ll&zip=98388&Go=Go
    // ripped from the web summary command
    sb = StringBuilder()
    buf as (byte) = array(byte, 8192)
    resStream as Stream = Stream.Null
    
    try:
      
      //Console.WriteLine(Utilities.TimeStamp() + "loading table...");
      request = cast(HttpWebRequest, WebRequest.Create((('http://www.zipinfo.com/cgi-local/zipsrch.exe?ll=ll&zip=' + zip.ToString()) + '&Go=Go')))
      
      response = cast(HttpWebResponse, request.GetResponse())
      
      resStream = response.GetResponseStream()
      
      tempString as string = null
      count = 0
      
      while true:
        // fill the buffer with data
        count = resStream.Read(buf, 0, buf.Length)
        
        // make sure we read some data
        if count != 0:
          // translate from bytes to ASCII text
          tempString = Encoding.ASCII.GetString(buf, 0, count)
          
          // continue building the string
          //char[] trimChars = {'\n'};
          sb.Append(tempString)
        break  unless (count > 0)
      // any more data to read?
      //Console.WriteLine(Utilities.TimeStamp() + "before parse attempt");
      
      // ok we now have a shitload of ugly html...
      // we want split[2] ...
      splitTokenOne as (string) = (zip,)
      splitStrings as (string) = sb.ToString().Split(splitTokenOne, StringSplitOptions.None)
      splitString as string = splitStrings[2].ToString()
      
      // quick grab here to get the info so we can parse out the city, state
      cityStateString as string = splitStrings[1].ToString()
      
      splitTokenTwo as (string) = ('</font></td></tr></table>',)
      splitStrings = splitString.Split(splitTokenTwo, StringSplitOptions.None)
      splitString = splitStrings[0].ToString()
      splitString = splitString.Replace('</font></td><td align=center>', ' ')
      splitString = splitString.Substring(1, (splitString.Length - 1))
      splitTokenThree as (string) = (' ',)
      latLongStrings as (string) = splitString.Split(splitTokenThree, StringSplitOptions.None)
      latLongs as (decimal) = (decimal.Parse(latLongStrings[0]), decimal.Parse(('-' + latLongStrings[1])))
      
      cityStateSplitTokenOne as (string) = ('(West)',)
      cityStateSplits as (string) = cityStateString.Split(cityStateSplitTokenOne, StringSplitOptions.None)
      cityStateString = cityStateSplits[1].ToString()
      cityStateString = cityStateString.Replace('</th></tr><tr><td align=center>', '')
      cityStateString = cityStateString.Replace('</font></td><td align=center>', '')
      
      cityStateSplitsTwo as (string) = (cityStateString.Substring(0, (cityStateString.Length - 2)).ToString(), cityStateString.Substring((cityStateString.Length - 2), 2).ToString())
      //Formatting.WriteToChannel(message.Channel,"Lat/Long for "+cityStateSplitsTwo[0]+", "+cityStateSplitsTwo[1]+": "+latLongs[0].ToString()+", "+latLongs[1].ToString());
      
      // feed to weather service
      weather = ndfdXML()
      weatherParams = weatherParametersType()
      
      //weatherParams.wx = true;    // Weather
      //weatherParams.maxt = true;  // High temp
      //weatherParams.mint = true;  // Low temp
      weatherParams.temp = true
      // 3 hour temperature
      weatherParams.appt = true
      // Apparent temp
      weatherParams.rh = true
      // relative humidity
      weatherParams.pop12 = true
      // 12-Hour chance of Precip
      weatherParams.wspd = true
      // wind speed
      weatherParams.sky = true
      // cloud coverage
      rawXML as string = weather.NDFDgen(latLongs[0], latLongs[1], 'time-series', System.DateTime.Now, System.DateTime.Now.AddDays(1), weatherParams)
      
      // remove tabs and newlines
      // which should leave us with just the mark-up..
      //Console.WriteLine(rawXML);
      
      wd as WeatherData = NdfdXMLParser.ParseWeatherXML(rawXML)
      
      windSpeedMPH as single = (single.Parse(wd.WindSpeed) * cast(single, 1.15077945))
      windSpeedMPH.ToString('N2')
      
      IrcConnection.SendPRIVMSG(message.Channel, (((((('Weather for ' + cityStateSplitsTwo[0]) + ', ') + cityStateSplitsTwo[1]) + ' (') + zip) + '):'))
      IrcConnection.SendPRIVMSG(message.Channel, (((((('Temperature: ' + wd.HourlyTemp) + 'F (Feels like ') + wd.ApparentTemp) + 'F) Humidity: ') + wd.RelativeHumidity) + '% '))
      IrcConnection.SendPRIVMSG(message.Channel, (((((('Cloud Coverage: ' + wd.CloudCoverage) + '% Chance of Precipitation: ') + wd.PrecipPercentage) + '% Wind Speed: ') + windSpeedMPH.ToString('N1')) + ' MPH'))
    
    
    except e as Exception:
      
      Console.WriteLine(('Ruh roh! Exception: ' + e.ToString()))
      IrcConnection.SendPRIVMSG(message.Channel, 'Something is b0rked with the weather fetch attempt.')
    
    

  #endregion
  
  
  
  #region whoistest_Command() DISABLED
  private static def whoistest_Command(message as IncomingMessage, displayDocs as bool):
    if displayDocs:
      // display syntax stuff here
      IrcConnection.SendPRIVMSG(message.Nick, 'Documentation for \'template\' command:')
      IrcConnection.SendPRIVMSG(message.Nick, 'Syntax: template <arguments1> <arguments2>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Alternative Syntax: template for <arguments1> and <arguments2>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Parameters: arguments1: First arguoment description. arguements2: Second argument description')
      IrcConnection.SendPRIVMSG(message.Nick, 'Purpose: Brief overview of the utility of this command.')
      
      return 
    
    // template stuff goes here
    if not Utilities.IsUserBotAdmin(message.Nick):
      return 
    
    IrcConnection.SendWHOIS(message.Args.Trim())
    
  #endregion
  
  #endregion
  

