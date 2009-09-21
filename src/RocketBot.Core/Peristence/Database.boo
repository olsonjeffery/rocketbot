namespace RocketBot.Core

import System
import System.Threading
import Db4objects.Db4o

public callable QueryForMany[of T](db as IObjectContainer) as T*
public callable QueryForSingle[of T](db as IObjectContainer) as T

public interface IPersistable:
  Id as Guid:
    get

public static class Database:
  rwl as ReaderWriterLock
  timeout = 10000
  db as IObjectContainer
  
  public def Initialize():
    rwl = ReaderWriterLock()
    dbPath = BotConfig.GetParameter("DatabasePath")
    db = Db4oFactory.OpenFile(dbPath)
  
  public def Teardown():
    db.Close()
  
  public def Query[of T(IPersistable)](query as QueryForMany[of T]) as T*:
    return query(db)
  
  public def Query[of T(IPersistable)](query as QueryForSingle[of T]) as T:
    return query(db)
  
  public def Store[of T(IPersistable)](item as T):
    db.Set(item)
  
  public def Delete[of T(IPersistable)](item as T):
    db.Delete(item)