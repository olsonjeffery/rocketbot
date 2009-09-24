namespace RocketBot.Core

import System
import System.Timers
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


  private _timer as System.Timers.Timer
  public Timer as System.Timers.Timer:
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
    _timer = Timer(interval * 60000)
    _timer.Elapsed += ElapsedEventHandler(invoker)
    _timer.Enabled = true
    
    
  

