﻿namespace RocketBot.Scripts

import System
import System.Net
import System.IO
import System.Text
import System.Collections.Generic
import System.Text.RegularExpressions
import RocketBot.Core
import HtmlAgilityPack
import System.Web

plugin WebSummaryPlugin:
  name "web_summary"
  desc "prints the <title> to a channel when a URL is pasted"
  version "0.1"
  author "pfox"
  
  docs web_summary:
    """
Web summary functionality
The bot will post a summary of a given link to the channel in which it was posted, if it is a valid HTML document with a <title> element in it.
    """
  
  raw_command "^.+PRIVMSG #[^ ]+ :.*http://[^ ]+.*":
    webMatch = Regex('(?<before>.*)(?<websummaryurl>http://[^ ]+)(?<after>.*)')
    if message.Command == 'websummary':
      return 
    
    webSummaryURLMatch as Match = webMatch.Match(message.Message)
    
    if not webSummaryURLMatch.Success:
      
      Console.WriteLine((Utilities.TimeStamp() + 'webSummaryURL match failed'))
    
    urlTitle = ""
    try:
      Utilities.DebugOutput('NEW: Found Web URL to summarize...')
      
      url = webSummaryURLMatch.Groups['websummaryurl'].Value.Trim()
      doc = HtmlDocument()
      doc.Load(GetStreamFromUrl(url))
  
      
      node = doc.DocumentNode.SelectSingleNode("html/head/title")
      if node is not null:
        urlTitle = node.InnerText
        urlTitle = Utilities.HtmlDecode(urlTitle).Replace("\n","").Replace("\t", "").Trim()
        if not urlTitle == string.Empty:
          IrcConnection.SendPRIVMSG(message.Channel, '"' + urlTitle + '"')
        
    except e as Exception:
      Console.WriteLine(((Utilities.TimeStamp() + 'EXCEPTION: ') + e.ToString()))

def GetStreamFromUrl(url as string):
  request = cast(HttpWebRequest, WebRequest.Create(url))
  
  response = cast(HttpWebResponse, request.GetResponse())
  
  return response.GetResponseStream()