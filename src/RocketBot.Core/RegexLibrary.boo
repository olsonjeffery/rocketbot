namespace RocketBot.Core

import System
import System.Collections.Generic
import System.Text.RegularExpressions

public class RegexLibrary:
  private static _regexDict as Dictionary[of string, Regex]

  public static def Initialize():
    _regexDict = Dictionary[of string, Regex]()
    
    _regexDict.Add('channelTalkPattern', Regex((('^.+PRIVMSG ' + BotConfig.GetParameter('Channel')) + '.+$')))
    _regexDict.Add('IncomingMessagePattern', Regex('^.+PRIVMSG.+$'))
    _regexDict.Add('TopicMessagePattern', Regex('^.+TOPIC.+$'))
    
    _regexDict.Add('IRCMessageGroup', Regex('(?<nick>[^:!]+)!(?<hostcrap>.+) PRIVMSG (?<channel>.+) :(?<message>.+)'))
    _regexDict.Add('TopicMessageGroup', Regex('(?<nick>[^:!]+)!(?<hostcrap>.+) TOPIC (?<channel>#.+) :(?<message>.+)'))
    
    _regexDict.Add('botCommandPattern', Regex('^!.+'))
    _regexDict.Add('botCommandGroup', Regex('(?<command>[^! ]+)(?<args>.*)'))
    
    // natural language parsing
    _regexDict.Add('complexCommandGroup', Regex((((('(^' + BotConfig.GetParameter('IRCNick')) + '(,|:)\\s*(?<message>.+)$|^(?<message>.+),\\s*') + BotConfig.GetParameter('IRCNick')) + '$)')))
    
  public static def GetRegex(key as string) as Regex:
    
    return _regexDict[key]
    
  
  

