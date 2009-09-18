namespace RocketBot.Scripts

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
  
      urlTitle = doc.DocumentNode.SelectSingleNode("html/head/title").InnerText
      urlTitle = Utilities.HtmlDecode(urlTitle)
    except e as Exception:
      Console.WriteLine(((Utilities.TimeStamp() + 'EXCEPTION: ') + e.ToString()))
    
    IrcConnection.SendPRIVMSG(message.Channel, '"' + urlTitle + '"')

def GetStreamFromUrl(url as string):
  request = cast(HttpWebRequest, WebRequest.Create(url))
  
  response = cast(HttpWebResponse, request.GetResponse())
  
  return response.GetResponseStream()