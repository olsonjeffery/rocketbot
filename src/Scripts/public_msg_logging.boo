namespace RocketBot.Scripts

import System
import System.Collections.Generic
import System.Data
import RocketBot.Core
import Db4objects.Db4o

plugin ChannelLoggingPlugin:
  name "channel_logging"
  version "1"
  author "pfox"
  desc "logs every *public* message (in channel) that the bot receives"
  
  setup:
    pass
  
  raw_command '^.+PRIVMSG #[^ ]+ :.*':
    user = RocketBot.Core.User.GetByNick(message.Nick)
    msg = LogMessage.New(user, message.Channel, message.FullMessage)
    Utilities.DebugOutput(msg.ToString())

public class LogMessage(IPersistable, IComparable):
  
  [property(RocketBot.Core.User)]
  _user as RocketBot.Core.User
  
  [property(Channel)]
  _channel as string
  
  [property(Message)]
  _message as string
  
  [property(CreateDate)]
  _timestamp as DateTime
  
  private def constructor(user as RocketBot.Core.User, channel as string, message as string, timestamp as DateTime):
    User = user
    Channel = channel
    Message = message
    CreateDate = timestamp
  
  public override def ToString() as string:
    return _timestamp.ToShortDateString() +" " + _timestamp.ToLongTimeString() + " " + _channel + " <"+_user.Nick+"> "+ _message
  
  public static def New(user as RocketBot.Core.User, channel as string, message as string) as LogMessage:
    msg = LogMessage(user, channel, message, DateTime.Now)
    Database.Store(msg)
    return msg
  
  public static def NewestMessageFrom(nick as string) as LogMessage:
    query = {x as IObjectContainer | x.Query[of LogMessage]({y as LogMessage | y.User.Nick == nick})} as QueryForMany[of LogMessage]
    results = List of LogMessage(Database.Query[of LogMessage](query))
    if results.Count == 0:
      return null
    else:
      sorted = List of LogMessage(results)
      sorted.Sort()
      sorted.Reverse()
      return sorted[0]
   
   public def CompareTo(logMsg as object):
     return _timestamp.CompareTo((logMsg as LogMessage).CreateDate)