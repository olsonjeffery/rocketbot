namespace RocketBot.Core

import System
import System.Threading
import Db4objects.Db4o
import System.Linq.Enumerable from System.Core

public callable QueryForMany[of T](db as IObjectContainer) as T*
public callable QueryForSingle[of T](db as IObjectContainer) as T

public interface IPersistable:
  Id as Guid:
    get
  
  CreateDate as date:
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
    rwl.AcquireReaderLock(timeout)
    result = query(db)
    rwl.ReleaseReaderLock()
    return result
  
  public def Query[of T(IPersistable)](query as QueryForSingle[of T]) as T:
    rwl.AcquireReaderLock(timeout)
    result = query(db)
    rwl.ReleaseReaderLock()
    return result
  
  public def Store[of T(IPersistable)](item as T):
    rwl.AcquireWriterLock(timeout)
    db.Set(item)
    rwl.ReleaseWriterLock()
  
  public def Delete[of T(IPersistable)](item as T):
    rwl.AcquireWriterLock(timeout)
    db.Delete(item)
    rwl.ReleaseWriterLock()
  
  public def FromGuid[of T(IPersistable)](id as Guid) as T:
    query = {x as IObjectContainer | x.Query[of T]({ y as T | (y as IPersistable).Id == id}).Single()}
    rwl.AcquireReaderLock(timeout)
    result = query(db)
    rwl.ReleaseReaderLock()
    return result