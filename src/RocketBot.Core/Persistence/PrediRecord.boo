
namespace PredibotLib

import System
import System.Collections
import System.Collections.Generic
import System.Text
import System.Text.RegularExpressions
import System.Data
import System.IO
import System.Reflection
import Db4objects.Db4o
import Db4objects.Db4o.Query

public abstract class PrediRecord:

	
	public def Update():
		BotDB.DBConn.Set(self)
		BotDB.DBConn.Commit()

	public def Save():
		Update()

	public def Create():
		Update()

	
	
	// delete this from the db and zero out
	// the members
	public abstract def Delete():
		pass
	
	


public static class BotDB:

	
	private static _dbConn as IObjectContainer

	public static DBConn as IObjectContainer:
		static get:
			return _dbConn

	
	#region Database Setup/Teardown methods
	
	public static def InitializeDB4O(path as string):
		
		
		//Utilities.DebugOutput("Checking if DB is already initialized...");
		Utilities.DebugOutput('Checking for Initialization...')
		
		// fire up the db... if no file exists, it creates a new one
		lock typeof(BotDB):
			
			Utilities.DebugOutput('Opening DB Connection...')
			_dbConn = Db4oFactory.OpenFile(path)
		
		//Db4objects.Db4o.Config.IConfiguration config = Db4oFactory.Configure();
		//config.
		

	public static def CloseDBConnection():
		
		lock typeof(BotDB):
			
			Utilities.DebugOutput('Closing DB...')
			_dbConn.Close()
		

	
	#endregion
	
	public static IsDBLocked as bool:
		static get:
			
			// figure out if the database is locked.
			return true

	
	public static def Query[of T](match as Predicate[of T]) as List[of T]:
		lock typeof(BotDB):
			tempList as IList[of T] = _dbConn.Query(match)
			
			return List[of T](tempList)

	
	public static def Get(template as object) as IObjectSet:
		lock typeof(BotDB):
			return _dbConn.Get(template)

	
	public static def Set(obj as object):
		lock typeof(BotDB):
			_dbConn.Set(obj)
			_dbConn.Commit()

	
	public static def Delete(obj as object):
		lock typeof(BotDB):
			_dbConn.Delete(obj)
			_dbConn.Commit()

	
	public static def GetAllOfType[of T]() as List[of T]:
		
		lock typeof(BotDB):
			
			return Query[of T]({ item as T | return true })
		
		
	
	
	


