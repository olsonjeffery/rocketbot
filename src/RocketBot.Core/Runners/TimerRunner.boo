namespace RocketBot.Core

import System
import System.Net
import System.Net.Sockets
import System.IO
import System.Threading
import System.Data
import System.Collections
import System.Collections.Generic
import System.Text
import System.Text.RegularExpressions
import System.Xml

public static class TimerRunner:

  
  private static _lexicon as Dictionary[of string, TimerItem]

  
  public static def Initialize():
    // the dictionary that contains the string/value pairs pointing to
    _lexicon = Dictionary[of string, TimerItem]()
    // set up the command syntax dict, which does all of out syntax parsing for
    // us...

  
  public static def RegisterCommand(commandInfo as CommandWrapper):
    pass
    
    // set up the TimerItem
    
    //_lexicon.Add()
    
  


public class TimerItem:

  private _timer as System.Threading.Timer

  public Timer as System.Threading.Timer:
    get:
      return _timer

  private _name as string

  public Name as string:
    get:
      return _name

  private _method as TimerCommand

  public Method as TimerCommand:
    get:
      return _method

  
  public def constructor(name as string, interval as int, method as TimerCommand):
    _name = name
    _timer = Timer(TimerCallback(method), null, (interval * 60000), (interval * 60000))
    
    
  
