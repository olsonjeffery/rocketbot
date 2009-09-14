
namespace PredibotLib

import System
import System.Collections.Generic
import System.Text
import PredibotLib.Configuration as Configuration

public class Utilities:

	
	public static def DebugOutput(message as string):
		
		if PredibotLib.Configuration.GetParameter('DebugOutput') == 'True':
			Console.WriteLine((TimeStamp() + message))
		

	
	
	public static def TimeStamp() as string:
		now as date = System.DateTime.Now
		
		
		return (now.ToLongTimeString() + ' - ')
		//return now.Hour.ToString() + ":" + now.Minute.ToString() + ":" + now.Second.ToString() + " - ";
		

	
	public static def IsUserBotAdmin(nick as string) as bool:
		
		returnValue = false
		
		// first determine that the user is in our valid list of
		// stored users
		if not User.DoesUserExistByNick(nick):
			
			return returnValue
			
		
		// next let's check if the user is identified to nickserv
		if not IrcConnection.IsNickIdentifiedToServices(nick):
			return returnValue
		
		// let's get the list of bot admins
		botAdmins as (string) = PredibotLib.Configuration.GetParameter('BotAdmins').Split(char(','))
		for admin as string in botAdmins:
			
			if admin == nick:
				Utilities.DebugOutput((('User ' + nick) + ' is an admin.'))
				returnValue = true
				
			
		
		if returnValue == false:
			Utilities.DebugOutput((('User ' + nick) + ' is NOT an admin.'))
		
		return returnValue
	

