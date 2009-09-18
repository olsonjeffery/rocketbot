namespace RocketBot.Core

import System
import System.Web

public class Utilities:

  
  public static def DebugOutput(message as string):
    
    if BotConfig.GetParameter('DebugOutput') == 'True':
      Console.WriteLine((TimeStamp() + message))
    

  
  
  public static def TimeStamp() as string:
    now as date = System.DateTime.Now
    
    
    return (now.ToLongTimeString() + ' - ')
    //return now.Hour.ToString() + ":" + now.Minute.ToString() + ":" + now.Second.ToString() + " - ";
    

  
  public static def IsUserBotAdmin(nick as string) as bool:
    
    returnValue = false  
    
    // next let's check if the user is identified to nickserv
    if not IrcConnection.IsNickIdentifiedToServices(nick):
      return returnValue
    
    // let's get the list of bot admins
    botAdmins as (string) = BotConfig.GetParameter('BotAdmins').Split(char(','))
    for admin as string in botAdmins:
      
      if admin == nick:
        Utilities.DebugOutput((('User ' + nick) + ' is an admin.'))
        returnValue = true
        
      
    
    if returnValue == false:
      Utilities.DebugOutput((('User ' + nick) + ' is NOT an admin.'))
    
    return returnValue
  
  public static def HtmlDecode(input as string) as string:
    return HttpUtility.HtmlDecode(input)
  

