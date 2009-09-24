namespace RocketBot.Core

import System
import System.Threading
import System.Collections.Generic

public static class TimerRunner:
  _timerItems as List[of TimerItem]
  _pluginIds as Dictionary[of TimerCommand, Guid]
  public PluginIds as Dictionary[of TimerCommand, Guid]:
    get:
      return _pluginIds

  
  public def Initialize():
    _pluginIds = Dictionary[of TimerCommand, Guid]()
    _timerItems = List[of TimerItem]()
  
  public def RegisterCommand(commandInfo as CommandWrapper):
    _timerItems.Add(TimerItem(commandInfo.ExecutionInterval, commandInfo.TimerCommand))
    _pluginIds.Add(commandInfo.TimerCommand, commandInfo.PluginId)

public class TimerItem:


  private _timer as Timer
  public Timer as Timer:
    get:
      return _timer

  private _method as TimerCommand

  public Method as TimerCommand:
    get:
      return _method
  
  public def constructor(interval as int, method as TimerCommand):
    invoker = def():
      if PluginLoader.Plugins[TimerRunner.PluginIds[method]].IsEnabled:
        method()
    reset = AutoResetEvent(true)
    _timer = Timer(TimerCallback(invoker), reset, 0, 0)
    
    
  

