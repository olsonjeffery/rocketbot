
namespace Predibot

import System
import System.Net
import System.Net.Sockets
import System.IO
import System.Threading
import System.Data
import System.Collections
import System.Collections.Generic
import System.Text
import System.Text.RegularExpressions
import System.Reflection
import PredibotLib

public static class CoreCommands:

	
	public static def SetupCommands():
		// hello command
		//PredibotLib.PrivMSGRunner.RegisterCommand();
		
		// seen
		//PredibotLib.PrivMSGRunner.RegisterCommand());
		
		// export command test
		PredibotLib.PrivMSGRunner.RegisterCommand(PredibotLib.CommandWrapper((of string: 'export'), Regex('^(?<command>export) (?<args>.+)$'), export_Command))
		
		// import command test
		PredibotLib.PrivMSGRunner.RegisterCommand(PredibotLib.CommandWrapper((of string: 'import'), Regex('^(?<command>import) (?<args>.+)$'), import_Command))
		
		// web summary
		PredibotLib.RawMSGRunner.RegisterCommand(PredibotLib.CommandWrapper('websummary', Regex('^.+PRIVMSG #[^ ]+ :.*http://[^ ]+.*'), websummary_Command))
		

	
	
	
	#region websummary_Command()
	private static def websummary_Command(message as IncomingMessage):
		
		
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
			blahTwo as (string) = ('<\\title>',)
			splitOne as (string) = sb.ToString().Split(blah, StringSplitOptions.None)
			//string[] splitTwo = splitOne[1].ToString().Split(blahTwo, StringSplitOptions.None);
			titleCloseIndex as int = splitOne[1].IndexOf('</title>')
			
			urlTitle as string = splitOne[1].Substring(0, titleCloseIndex)
			
			IrcConnection.SendPRIVMSG(message.Channel, (('"' + urlTitle) + '"'))
			
			Database.CreateNewWebURL(message, webSummaryURLMatch.Groups['websummaryurl'].Value, urlTitle)
		
		/* 
                // doesn't work :/
                Match titleMatch = getTitleGroup.Match(sb.ToString());
                if (titleMatch.Success)
                {
                    Console.WriteLine("Inside of the check");
                    Formatting.WriteToChannel(message.Channel, "\""+titleMatch.Groups["title"].Value+"\"");

                }
                */
		
		
		
		
		except e as Exception:
			
			Console.WriteLine(((Utilities.TimeStamp() + 'EXCEPTION: ') + e.ToString()))
		

	#endregion
	
	public static def export_Command(message as IncomingMessage, displayDocs as bool):
		converterGeneratedName1 = message.Args.Trim()
		
		
		if converterGeneratedName1 == 'User':
			User.Export('userexport.prd')
		else:
			IrcConnection.SendPRIVMSG(message.Channel, (('No export functionality set up for the \'' + message.Args) + '\' type.'))
			return 
		

	
	public static def import_Command(message as IncomingMessage, displayDocs as bool):
		
		importSplit as (string) = message.Args.Trim().Split(char(' '))
		if importSplit.Length != 2:
			IrcConnection.SendPRIVMSG(message.Channel, 'You need to use the command like so: \'!import <type> <filename>\'')
			return 
		
		if not FileInfo(((Directory.GetCurrentDirectory() + Path.DirectorySeparatorChar) + importSplit[1])).Exists:
			IrcConnection.SendPRIVMSG(message.Channel, (('The import file \'' + importSplit[1]) + '\' does not exist.'))
			return 
		else:
			converterGeneratedName2 = importSplit[0]
			if converterGeneratedName2 == 'User':
				User.Import(importSplit[1])
			else:
				IrcConnection.SendPRIVMSG(message.Channel, (('There are no import rules for type \'' + importSplit[0]) + '\''))
				return 
		
	
	
	

