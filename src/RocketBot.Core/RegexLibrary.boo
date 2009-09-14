
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
import PredibotLib.Configuration as Configuration

public class RegexLibrary:

	
	private static _regexDict as Dictionary[of string, Regex]

	
	private def constructor():
		pass
		// private ctor

	
	public static def Initialize():
		_regexDict = Dictionary[of string, Regex]()
		
		_regexDict.Add('channelTalkPattern', Regex((('^.+PRIVMSG ' + PredibotLib.Configuration.GetParameter('Channel')) + '.+$')))
		_regexDict.Add('IncomingMessagePattern', Regex('^.+PRIVMSG.+$'))
		_regexDict.Add('TopicMessagePattern', Regex('^.+TOPIC.+$'))
		
		_regexDict.Add('IRCMessageGroup', Regex('(?<nick>[^:!]+)!(?<hostcrap>.+) PRIVMSG (?<channel>.+) :(?<message>.+)'))
		_regexDict.Add('TopicMessageGroup', Regex('(?<nick>[^:!]+)!(?<hostcrap>.+) TOPIC (?<channel>#.+) :(?<message>.+)'))
		
		_regexDict.Add('botCommandPattern', Regex('^!.+'))
		_regexDict.Add('botCommandGroup', Regex('(?<command>[^! ]+)(?<args>.*)'))
		
		_regexDict.Add('isURLPattern', Regex('^.*http://[^ ]+.*'))
		_regexDict.Add('webSummaryURLPattern', Regex('(?<before>.*)(?<websummaryurl>http://[^ ]+)(?<after>.*)'))
		_regexDict.Add('changeMatchPattern', Regex('(?<changeamount>(penny|nickel|dime|quarter)) (?<nick>[^ ]+)'))
		_regexDict.Add('changeNumericMatchPattern', Regex('(?<changenumericamount>[0-9]+) (?<nick>[^ ]+)'))
		
		
		// natural language parsing
		_regexDict.Add('naturalLanguagePattern', Regex((((('(^' + PredibotLib.Configuration.GetParameter('IRCNick')) + '(,|:)\\s*.+$|^.+,\\s*') + PredibotLib.Configuration.GetParameter('IRCNick')) + '$)')))
		_regexDict.Add('naturalLanguageGroup', Regex((((('(^' + PredibotLib.Configuration.GetParameter('IRCNick')) + '(,|:)\\s*(?<message>.+)$|^(?<message>.+),\\s*') + PredibotLib.Configuration.GetParameter('IRCNick')) + '$)')))
		

	
	public static def GetRegex(key as string) as Regex:
		
		return _regexDict[key]
		
	
	

