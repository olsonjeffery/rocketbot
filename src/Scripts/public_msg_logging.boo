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
    pass
  
  raw_command '^.+PRIVMSG #[^ ]+ :.*':
    pass

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
