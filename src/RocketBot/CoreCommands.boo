
namespace Predibot

import System
import System.Net
import System.IO
import System.Text
import System.Text.RegularExpressions
import PredibotLib

public static class CoreCommands:

	
	public def SetupCommands():
		// web summary
		PredibotLib.RawMSGRunner.RegisterCommand(PredibotLib.CommandWrapper('websummary', Regex('^.+PRIVMSG #[^ ]+ :.*http://[^ ]+.*'), websummary_Command))
		
	private def websummary_Command(message as IncomingMessage):
		
		
		// this is a dirty hack to avoid explicit execution of this command..
		// it should only be ran when a url and only a url, is pasted to the chan
		if message.Command == 'websummary':
			return 
		
		// test
		//Formatting.WriteToChannel(message.Channel, "It's a URL: " + message.Command);
		
		// ripped from http://www.csharp-station.com/HowTo/HttpWebFetch.aspx
		
		sb = StringBuilder()
		buf as (byte) = array(byte, 8192)
		
		webSummaryURLMatch as Match = RegexLibrary.GetRegex('webSummaryURLPattern').Match(message.Message)
		
		if not webSummaryURLMatch.Success:
			
			Console.WriteLine((Utilities.TimeStamp() + 'webSummaryURL match failed'))
			
		
		try:
			Utilities.DebugOutput('Found Web URL to summarize...')
			
			request = cast(HttpWebRequest, WebRequest.Create(webSummaryURLMatch.Groups['websummaryurl'].Value))
			
			response = cast(HttpWebResponse, request.GetResponse())
			
			resStream as Stream = response.GetResponseStream()
			
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
					sb.Append(tempString)
				break  unless (count > 0)
			// any more data to read?
			// our stream buffer should now have the goods..
			// we need to parse the <title> info out...
			
			// for testing
			//Console.WriteLine("Right before title match success check");
			
			// i cant get the regex right to make the below check work
			// (ie i want a regex expression to return everything
			// inside of the title brackets...
			// so im gonna do it really ghetoo w/ Split..
			//
			// also, as a sidenote... the people of #regex on freenode
			// say not to waste your time with doing regex on HTML, so
			// yeah...
			blah as (string) = ('<title>',)
			splitOne as (string) = sb.ToString().Split(blah, StringSplitOptions.None)
			//string[] splitTwo = splitOne[1].ToString().Split(blahTwo, StringSplitOptions.None);
			titleCloseIndex as int = splitOne[1].IndexOf('</title>')
			
			urlTitle as string = splitOne[1].Substring(0, titleCloseIndex)
			
			IrcConnection.SendPRIVMSG(message.Channel, (('"' + urlTitle) + '"'))
		
		
		except e as Exception:
			
			Console.WriteLine(((Utilities.TimeStamp() + 'EXCEPTION: ') + e.ToString()))