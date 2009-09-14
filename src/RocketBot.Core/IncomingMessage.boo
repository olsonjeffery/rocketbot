
namespace PredibotLib

import System
import System.Net
import System.Net.Sockets
import System.IO
import System.Threading
import System.Data
import System.Collections
import System.Collections.Generic
import System.Text.RegularExpressions

public class IncomingMessage:

	
	public RawMessage as string

	public Nick as string

	public Message as string

	public FullMessage as string

	public Channel as string

	public SenderHostInfo as string

	public Command as string

	public Args as string

	public User as User

	public MessageTime as DateTime

	
	// if this flag is flipped, then when we call the command_Command(),
	// we display documentation for it. This is always set to false by
	// default, and will only be flipped to true when processed through
	// the !help command
	public DisplayDocs as bool

	
	// -1 = unimplemented/catchall .. do nothing
	// 0 = IRC Message, ie PRIVMSG to channel or user
	// 1 = an IRC Message that is also a bot command
	// 2 = Topic, ie TOPIC change or initial view on join
	// 3 = Natural language bot command
	// 4 = PONG reply from server
	// 5 = url?
	public MessageType as int

	
	public def constructor(rawMessage as string):
		
		MessageTime = DateTime.Now
		
		RawMessage = rawMessage
		
		User = User('.', DateTime.Now)
		DisplayDocs = false
		
		m as Match = RegexLibrary.GetRegex('IRCMessageGroup').Match(RawMessage)
		if m.Success:
			
			if m.Success:
				Console.WriteLine((((((Utilities.TimeStamp() + m.Groups['channel']) + ':') + m.Groups['nick'].Value) + ' said: ') + m.Groups['message'].ToString()))
			
			Nick = m.Groups['nick'].Value
			Channel = m.Groups['channel'].Value
			Message = m.Groups['message'].Value.Trim()
			FullMessage = Message
			SenderHostInfo = m.Groups['hostcrap'].Value
			
			
			
			// check if we have a command here
			botCommandMatch as Match = RegexLibrary.GetRegex('botCommandGroup').Match(Message)
			
			if RegexLibrary.GetRegex('botCommandPattern').IsMatch(Message):
				// if the match worked..
				
				Command = botCommandMatch.Groups['command'].Value
				Args = botCommandMatch.Groups['args'].Value.Trim()
				if Args == '':
					Message = Command
				else:
					Message = ((Command + ' ') + Args)
				
				MessageType = 1
			elif RegexLibrary.GetRegex('naturalLanguageGroup').IsMatch(Message):
			
			// natural language check
				m = RegexLibrary.GetRegex('naturalLanguageGroup').Match(Message)
				if m.Success:
					
					Message = m.Groups['message'].Value
					m2 as Match = RegexLibrary.GetRegex('botCommandGroup').Match(Message)
					
					if m2.Success:
						// if this is a natural language, let's just mark it and pass
						// it on for a downstream method to parse
						MessageType = 3
						Command = m2.Groups['command'].Value
						Args = m2.Groups['args'].Value.Trim()
						
				
				return 
			else:
				
				// the match didnt work, ie this isn't a command
				Command = ''
				Args = ''
				MessageType = 0
				
				Utilities.DebugOutput('Non-command IRC Message.')
				
			
			return 
			
			// end of IRC message if struct
		
		
		
		
		// check if it's a TOPIC?
		m = RegexLibrary.GetRegex('TopicMessageGroup').Match(RawMessage)
		if m.Success:
			
			Message = m.Groups['message'].Value
			FullMessage = Message
			Nick = m.Groups['nick'].Value
			Channel = m.Groups['channel'].Value
			SenderHostInfo = m.Groups['hostcrap'].Value
			MessageType = 2
			Command = ''
			Args = ''
			
			// we have a topic change!
			Utilities.DebugOutput(((('Topic change: "' + Message) + '" by ') + Nick))
			
			return 
			
		
		// check if it's a VERSION
		
		// PING/PONG check?
		
		// If it's anything else ?
		if true:
			
			//throw new Exception("The message parse did not work. Not good.");
			Message = ''
			FullMessage = ''
			Nick = ''
			Channel = ''
			SenderHostInfo = ''
			Command = ''
			Args = ''
			MessageType = (-1)
			
			Utilities.DebugOutput('Unmatched message type?')
			
			
		
	

