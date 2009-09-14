
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

public class User(PrediRecord):

	private _nick as string

	public Nick as string:
		get:
			return _nick
		set:
			_nick = value.ToLower()

	private _introDate as DateTime

	public IntroDate as date:
		get:
			return _introDate

	
	public def constructor(nick as string, introDate as date):
		
		// nick and introDate are really the only manditory infos we need...
		// the rest can be filled in as we go
		_nick = nick.ToLower()
		_introDate = introDate
		// bye, bye!
		//PunDebt = 0.0F;
		//LastPunAmount = 0.0F;
		

	
	#region Comparers
	public static def CompareByNick(item1 as User, item2 as User) as int:
		
		return Comparer[of string].Default.Compare(item1.Nick, item2.Nick)
		

	
	public static def CompareByIntroDate(item1 as User, item2 as User) as int:
		
		return Comparer[of date].Default.Compare(item1.IntroDate, item2.IntroDate)
		

	/*
        public static int CompareByPunDebt(User item1, User item2)
        {

            return Comparer<float>.Default.Compare(item1.PunDebt, item2.PunDebt);

        }
         */
	
	#endregion
	
	#region Import/Export
	public static def Import(fileName as string) as bool:
		//
		
		Utilities.DebugOutput(('Importing type \'User\' from ' + fileName))
		importFileInfo = FileInfo(((Directory.GetCurrentDirectory() + Path.DirectorySeparatorChar) + fileName))
		
		if not importFileInfo.Exists:
			return false
		
		file as FileStream = importFileInfo.Open(FileMode.Open, FileAccess.Read)
		
		reader = StreamReader(file)
		
		
		line as string
		while (line = reader.ReadLine()) is not null:
			
			// put all the stuff you want to export
			// in here as items in the array and be
			// sure to turn them into strings!
			lineArr as (string) = line.Split((of string: '<~~>'), StringSplitOptions.None)
			if lineArr.Length != 4:
				return false
			user as User
			if User.DoesUserExistByNick(lineArr[0]):
				user = User.Get(lineArr[0])
			else:
				user = User(lineArr[0].ToLower(), DateTime.Parse(lineArr[1]))
			
			BotDB.Set(user)
		
		
		reader.Close()
		file.Close()
		
		return true
		

	
	public static def Export(fileName as string):
		
		Utilities.DebugOutput('Exporting all files of type \'User\'')
		exportFileInfo = FileInfo(((Directory.GetCurrentDirectory() + Path.DirectorySeparatorChar) + fileName))
		
		file as FileStream = exportFileInfo.Open(FileMode.OpenOrCreate, FileAccess.ReadWrite)
		
		writer = StreamWriter(file)
		
		list as List[of User] = BotDB.GetAllOfType[of User]()
		
		if list.Count == 0:
			return 
		else:
			
			for item as User in list:
				
				// put all the stuff you want to export
				// in here as items in the array and be
				// sure to turn them into strings!
				lineArr as (string) = (item.Nick.ToLower(), ((item.IntroDate.ToShortDateString() + ' ') + item.IntroDate.ToLongTimeString()))
				//item.PunDebt.ToString("N2"),
				//item.LastPunAmount.ToString("N2")
				
				line as string = String.Join('<~~>', lineArr)
				writer.Write(line)
				writer.WriteLine()
				writer.Flush()
				
			
			writer.Close()
			file.Close()
			
		
		

	
	#endregion
	
	public override def Delete():
		//
		BotDB.Delete(self)
		Nick = ''
		_introDate = DateTime.Now
		

	
	#region Static Methods
	public static def DoesUserExistByNick(nick as string) as bool:
		
		nick = nick.ToLower()
		
		users as List[of User] = BotDB.Query[of User]({ user as User | return (user.Nick == nick) })
		
		// if this list is empty, that means
		// the user doesn't exist
		if users.Count == 0:
			Utilities.DebugOutput((('User ' + nick) + ' doesn\'t exist.'))
			return false
		elif users.Count > 1:
			// this is a problem, we're storing more than
			// one User object with the same nick... shouldn't
			// the Set() update be working?
			Utilities.DebugOutput(('FUCK! Duplicate users found: ' + nick))
			// we don't want to create anymore users with this nick!
			return true
		else:
			return true
		

	
	public static def Get(nick as string) as User:
		
		nick = nick.ToLower()
		
		users as List[of User] = BotDB.Query[of User]({ user as User | return (user.Nick == nick) })
		
		if users.Count == 0:
			
			// the user doesn't exist, but we don't want to error out
			// so if the user's nick is . , then we know the user
			// isn't there... this is so that !seen doesn't make the
			// system crash if the user doesn't exist
			
			return User('.', DateTime.Now)
		elif users.Count > 1:
		
			raise Exception('Fetch attempt returned multiple results: BAD NEWS!')
		elif users.Count == 1:
			Utilities.DebugOutput(('Found user: ' + users[0].Nick))
			Utilities.DebugOutput('Getting ready to close DB on successful GetUserByNick() run')
			
			return users[0]
		else:
			// success!
			raise Exception('the result of users is != 1, 0 and isn\'t > 1... still bad!')
		
		
		

	public static def Get() as List[of User]:
		return BotDB.GetAllOfType[of User]()
	
	#endregion
	
	

