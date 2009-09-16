namespace RocketBot.Core

import System
import CS_SQLite3
import System.Threading
import System.Data

public static class Database:
  _db as SQLiteDatabase
  rwl as ReaderWriterLock
  
  public def Initialize():
    _db = SQLiteDatabase(BotConfig.GetParameter('DatabasePath'))
    rwl = ReaderWriterLock()
    
    tables = _db.GetTables()
    containsTableList = false
    for table as string in tables:
      containsTableList = true if table == 'TableList'
    SetupTableList() if not containsTableList
  
  public def SetupTableList():
    Utilities.DebugOutput('Creating TableList. Should only happen once.')
    ExecuteNonQuery('CREATE TABLE TableList(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, version INTEGER);')
  
  public def ExecuteNonQuery(query as string):
    rwl.AcquireWriterLock(10000)
    
    _db.ExecuteNonQuery(query)
    
    rwl.ReleaseWriterLock()
  
  public def ExecuteQuery(query as string) as DataTable:
    rwl.AcquireReaderLock(10000)
    
    result = _db.ExecuteQuery(query)
    
    rwl.ReleaseReaderLock()
    
    return result