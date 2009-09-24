namespace RocketBot.Scripts

import System
import System.Text.RegularExpressions
import System.Collections.Generic
import HtmlAgilityPack
import RocketBot.Core

plugin TwitterPlugin:
  name "twitter"
  desc "provides a service to poll for and show new twitter messages from a given user in a given channel"
  author "pfox"
  version "1"
  
  setup:
    TwitterMessages.Initialize()
    if BotConfig.HasParameter('TwitterUsers'):
      delim = ( ',' , '}{@#$}{}{@}' )
      result = BotConfig.GetParameter('TwitterUsers').Split(delim, StringSplitOptions.None)
      for screenName as string in result:
        try:
          screenName = screenName.Trim()
          delim = ('|',  "@$#@$#@$@")
          snAndChannel = screenName.Split(delim, StringSplitOptions.None)
          TwitterMessages.AddUser(snAndChannel[0], snAndChannel[1])
        except e:
          raise "error parsing config file for TwitterUsers for following item: '"+screenName+"'"
  
  bot_command addtwit:
    if not Utilities.IsUserBotAdmin(message.Nick):
      IrcConnection.SendPRIVMSG(message.Channel, "sorry, only bot admins can add twitter users.")
      return
    TwitterMessages.AddUser(message.Args, message.Channel)
    IrcConnection.SendPRIVMSG(message.Channel, "Okay! Twitter messages from '"+message.Args+"' will now appear in '"+message.Channel+"'!")
  
  bot_command removetwit:
    if not Utilities.IsUserBotAdmin(message.Nick):
      IrcConnection.SendPRIVMSG(message.Channel, "sorry, only bot admins can remove twitter users.")
      return
    TwitterMessages.RemoveUser(message.Args)
    IrcConnection.SendPRIVMSG(message.Channel, "Twitter messages from '"+message.Args+"' will no longer be displayed.")
  
  timer_command 2:
    for user as string in TwitterMessages.GetUsers():
      update = Utilities.HtmlDecode(GetUpdateForUser(user))
      if update == string.Empty:
        Utilities.DebugOutput("'"+user+"' is not a valid twitter user. Removing from twitter user list.")
      elif not TwitterMessages.MessageMatchesLastUpdate(user, update):
        TwitterMessages.ChangeLastUpdate(user, update)
        IrcConnection.SendPRIVMSG(TwitterMessages.GetChannelForUser(user), "Twitter: "+user+" said: '"+update+"'")

def GetUpdateForUser(user as string) as string:
  doc = HtmlDocument()
  doc.Load(GetStreamFromUrl('http://twitter.com/users/show.xml?screen_name='+user))
  if doc.DocumentNode.SelectSingleNode('hash/error') is not null:
    TwitterMessages.RemoveUser(user)
    return string.Empty
  else:
    return doc.DocumentNode.SelectSingleNode('user/status/text').InnerText.Trim()

public static class TwitterMessages:
  _lastUpdateByUser as Dictionary[string, string]
  _channelsForUser as Dictionary[string, string]
  
  public def Initialize():
    _lastUpdateByUser = Dictionary[of string, string]()
    _channelsForUser = Dictionary[of string, string]()
  
  public def AddUser(user as string, channel as string):
    _channelsForUser[user] = channel
    _lastUpdateByUser[user] = string.Empty
  
  public def RemoveUser(user as string):
    _lastUpdateByUser.Remove(user)
    _channelsForUser.Remove(user)
  
  public def ChangeLastUpdate(user as string, message as string):
    _lastUpdateByUser[user] = message
  
  public def MessageMatchesLastUpdate(user as string, newMessage as string) as bool:
    return _lastUpdateByUser[user] == newMessage
  
  public def GetChannelForUser(user as string) as string:
    return _channelsForUser[user]
  
  public def GetUsers():
    return _lastUpdateByUser.Keys