namespace RocketBot.Scripts

import System
import System.Xml
import System.Text.RegularExpressions
import System.Net
import System.IO
import System.Text
import System.Web
import RocketBot.Core
import HtmlAgilityPack
import System.Web.Services.Protocols

plugin EtymPlugin:
  name "etym"
  version "0.1"
  author "pfox"
  desc "gets etymology information from www.etymonline.com"
  
  docs etym:
    """
Documentation for the \'etym\' command:
Synonyms: none
Syntax: etym <word>
Alternative Syntax: none
Parameters: word: a single word to look up in the dictionary
Purpose: Provides etymological information on the provided word.
    """
  
  bot_command etym:
    if message.Args is null or string.Empty.Equals(message.Args):
      IrcConnection.SendPRIVMSG(message.Channel, "I need a word to look up. Can ya help me out?")
      return
    spaceL = List of string()
    spaceL.Add(" ")
    space = spaceL.ToArray()
    url = String.Format('http://www.etymonline.com/index.php?search={0}&searchmode=term', message.Args.Split(space, StringSplitOptions.None)[0])
    url = url.Replace(" ", '%20')
    print url
    doc = HtmlDocument()
    doc.Load(GetStreamFromUrl(url))
    
    stripHTML = Regex("<.?>")
    
    if doc.DocumentNode.SelectSingleNode('html/body/div[@id="container"]/div[@id="dictionary"]/dl') is null:
      IrcConnection.SendPRIVMSG(message.Channel, "Sorry, www.etymonline.com doesn't have an entry for '"+message.Args+"'")
    else:
      title = Utilities.HtmlDecode(doc.DocumentNode.SelectSingleNode('html/body/div[@id="container"]/div[@id="dictionary"]/dl/dt[1]').InnerText)
      title = stripHTML.Replace(title, "", Int32.MaxValue)
      definition = Utilities.HtmlDecode(doc.DocumentNode.SelectSingleNode('html/body/div[@id="container"]/div[@id="dictionary"]/dl/dd[1]]').InnerText)
      definition = stripHTML.Replace(definition, "", Int32.MaxValue)
      
      IrcConnection.SendPRIVMSG(message.Channel, title+":")
      IrcConnection.SendBufferedPRIVMSG(message.Channel, definition, 256)