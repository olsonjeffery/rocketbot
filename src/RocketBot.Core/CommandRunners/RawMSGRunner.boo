namespace RocketBot.Core

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
import System.Xml

public static class RawMSGRunner:

	
	private static _lexicon as Dictionary[of string, RawMSGCommand]

	private static _commandSyntaxDict as Dictionary[of string, Regex]

	
	public static def Initialize():
		// the dictionary that contains the string/value pairs pointing to
		_lexicon = Dictionary[of string, RawMSGCommand]()
		// set up the command syntax dict, which does all of out syntax parsing for
		// us...
		_commandSyntaxDict = Dictionary[of string, Regex]()

	
	public static def RegisterCommand(commandInfo as CommandWrapper):
		
		_lexicon.Add(commandInfo.Names[0], commandInfo.RawMSGMethod)
		_commandSyntaxDict.Add(commandInfo.Names[0], commandInfo.SyntaxPattern)
		

	
	#region ExecuteCommands
	
	public static def ExecuteCommand(commandTemp as string, message as IncomingMessage):
		
		try:
			command = cast(RawMSGCommand, _lexicon[commandTemp])
			
			ActionQueue.EnqueueItem(ActionItem(message, command))
		except e as Exception:
			
			// blah!
			Console.WriteLine(((Utilities.TimeStamp() + 'Whoops! Exception in ExecuteCommand(string, IncomingMessage): ') + e.ToString()))
		
		

	
	public static def ParseMessage(message as IncomingMessage):
		
		for key as string in _lexicon.Keys:
			m as Match = _commandSyntaxDict[key].Match(message.RawMessage)
			if m.Success:
				ExecuteCommand(key, message)
		
	
	#endregion
	

