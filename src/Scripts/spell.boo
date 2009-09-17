namespace RocketBot.Scripts

import System
import RocketBot.Core
import System.Text
import System.Text.RegularExpressions
import System.Net
import System.IO

plugin SpellCommand:
  name "spell"
  version "0.1"
  author "pfox"
  desc "checks for proper spelling of a word"
  bot_command spell:
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