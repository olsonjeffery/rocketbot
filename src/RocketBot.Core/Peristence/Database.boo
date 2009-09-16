namespace RocketBot.Core

import System
import CS_SQLite3
import System.Threading
import System.Data

public static class Database:
  db as SQLiteDatabase
  rwl as ReaderWriterLock
  timeout = 10000
  
  public def Initialize():
    db = SQLiteDatabase(BotConfig.GetParameter('DatabasePath'))
    rwl = ReaderWriterLock()
    SetupTableList() if not DoesTableExist('TableList')
  
  public def SetupTableList():
    Utilities.DebugOutput('Creating TableList. Should only happen once.')
    ExecuteNonQuery('CREATE TABLE TableList(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, version INTEGER);')
  
  public def ExecuteNonQuery(query as string):
    rwl.AcquireWriterLock(timeout)
    
    db.ExecuteNonQuery(query)
    
    rwl.ReleaseWriterLock()
  
  public def SanitizeString(input as string):
    input = input.Replace("'", "''")
    return input
  
  public def GetTableVersion(tableName as string) as int:
    tableName = SanitizeString(tableName)
    
    return -1 if not DoesTableExist(tableName)
    result = ExecuteQuery("SELECT version FROM TableList WHERE name = '"+tableName+"';")
    return Int32.Parse(result.Rows[0][0].ToString())
  
  public def DoesTableExist(tableName as string) as bool:
    rwl.AcquireReaderLock(timeout)
    
    tables = db.GetTables()
    containsTable = false
    for table as string in tables:
      containsTable = true if table == tableName
    
    rwl.ReleaseReaderLock()
    
    return containsTable
  
  public def ExecuteQuery(query as string) as DataTable:
    rwl.AcquireReaderLock(timeout)
    
    result = db.ExecuteQuery(query)
    
    rwl.ReleaseReaderLock()
    
    return result