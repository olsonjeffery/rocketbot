
namespace RocketBot.Core

import System
import System.Data
import System.Collections.Generic

public final class BotConfig:

  
  // this is the actual config, held in a 
  // datarow. yip yip yip!
  private static config as DataRow = null
  
  private static _usableConfig as Dictionary[of string, string]
  
  public static def Initialize(path as string, configPiece as string):
    
    _usableConfig = Dictionary[of string, string]()
    
    // i suppose its fair to say that this is a pretty kludgey
    // way to implement the whole config affair (ie via a datarow
    // in a handjammed config file)... but it appears that
    // System.Configuration isn't implemented fully/properly(?)
    // in mono (judging by all the stubbed out methods), so this
    // is how it's gonna be done...
    ds = DataSet()
    columnNames = List of string()
    try:      
      ds.ReadXml(path)
      config = ds.Tables[configPiece].Rows[0]  
      for i as DataColumn in ds.Tables[configPiece].Columns:
        columnNames.Add(i.ColumnName)
    except e as Exception:
      // log call here
      Utilities.DebugOutput('Failure to initialize Configuration: ' + e.ToString())
    
    for name in columnNames:
      _usableConfig[name] = ReadFromConfigFile(name)
    
    
  public static def Initialize():
    path = 'RocketBot.config.xml'
    Initialize(((System.Environment.CurrentDirectory.ToString() + System.IO.Path.DirectorySeparatorChar.ToString()) + path), 'RocketBotConfiguration')

  public static def ReadFromConfigFile(param as string) as string:
    
    if (config[param].ToString().Trim() is null) or (config[param].ToString().Trim() == ''):
      
      raise Exception('Non-existent/invalid configuration parameter selected')
    else:
      
      return config[param].ToString().Trim()
  
  public static def HasParameter(param as string) as bool:
    return true if _usableConfig.ContainsKey(param)
    return false
  
  public static def GetParameter(param as string) as string:
    raise "configuration does not contain '"+param+"' parameter" if not _usableConfig.ContainsKey(param)
    return _usableConfig[param]
  
  public static def SetParameter(key as string, value as string):
    _usableConfig[key] = value;