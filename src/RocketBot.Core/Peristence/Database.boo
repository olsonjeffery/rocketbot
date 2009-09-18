namespace RocketBot.Core

import System
import System.Threading

public static class Database:
  rwl as ReaderWriterLock
  timeout = 10000
  
  public def Initialize():
    rwl = ReaderWriterLock()
