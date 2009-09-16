namespace RocketBot.Scripts

import System
import System.Data
import RocketBot.Core

plugin ChannelLoggingPlugin:
  name "channel_logging"
  version "1"
  author "pfox"
  desc "logs every *public* message (in channel) that the bot receives"
  
  setup:
    tableVersion = Database.GetTableVersion('ChannelLog')
    if tableVersion == -1:
      Utilities.DebugOutput('Creating ChannelLogging table')
      Database.ExecuteNonQuery('CREATE TABLE ChannelLog(id INTEGER PRIMARY KEY AUTOINCREMENT, nick TEXT, channel TEXT, message TEXT, timestamp TEXT);')
      Database.ExecuteNonQuery("INSERT INTO TableList (name, version) VALUES ('ChannelLog', 1);");
    
  
  raw_command '^.+PRIVMSG #[^ ]+ :.*':
    if message.MessageType in (0,1,3):
      msg = Database.SanitizeString(message.FullMessage)
      now = DateTime.Now
      timestamp = now.ToShortDateString() + " " + now.ToLongTimeString()
      query = "INSERT INTO ChannelLog (nick, channel, message, timestamp) VALUES ('"+message.Nick+"', '"+message.Channel+"', '"+msg+"', '"+timestamp+"');"
      Utilities.DebugOutput(query)
      Database.ExecuteNonQuery(query)

public class LogMessage:
  
  [property(Nick)]
  _name as string
  
  [property(Channel)]
  _channel as string
  
  [property(Message)]
  _message as string
  
  [property(Timestamp)]
  _timestamp as DateTime
  
  public def constructor(nick as string, channel as string, message as string, timestamp as DateTime):
    Nick = nick
    Channel = channel
    Message = message
    Timestamp = timestamp