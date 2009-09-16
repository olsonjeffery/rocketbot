namespace RocketBot.Core

import System
import CS_SQLite3
import System.Threading
import System.Data

public static class Database:
  _db as SQLiteDatabase
  rwl as ReaderWriterLock
  timeout = 10000
  
  public def Initialize():
    _db = SQLiteDatabase(BotConfig.GetParameter('DatabasePath'))
    rwl = ReaderWriterLock()
    SetupTableList() if not DoesTableExist('TableList')
  
  public def SetupTableList():
    Utilities.DebugOutput('Creating TableList. Should only happen once.')
    ExecuteNonQuery('CREATE TABLE TableList(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, version INTEGER);')
  
  public def ExecuteNonQuery(query as string):
    rwl.AcquireWriterLock(timeout)
    
    _db.ExecuteNonQuery(query)
    
    rwl.ReleaseWriterLock()
  
  public def DoesTableExist(tableName as string) as bool:
    rwl.AcquireReaderLock(timeout)
    
    tables = _db.GetTables()
    containsTable = false
    for table as string in tables:
      containsTable = true if table == tableName
    
    rwl.ReleaseReaderLock()
    
    return containsTable
  
  public def ExecuteQuery(query as string) as DataTable:
    rwl.AcquireReaderLock(timeout)
    
    result = _db.ExecuteQuery(query)
    
    rwl.ReleaseReaderLock()
    
    return result