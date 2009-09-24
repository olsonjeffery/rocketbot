namespace RocketBot.Core

import System
import System.Collections.Generic
import System.Text.RegularExpressions

public callable PrivMSGCommand(message as IncomingMessage, displayDocs as bool) as void
public callable RawMSGCommand(message as IncomingMessage) as void
public callable TimerCommand() as void

public enum CommandType:
  RawMSGCommand
  PrivMSGCommand
  TimerCommand
  ComplexCommand
  PubSubCommand


public class CommandWrapper:

  private _names as List[of string]

  public Names as List[of string]:
    get:
      return _names

  private _syntaxPattern as Regex

  public SyntaxPattern as Regex:
    get:
      return _syntaxPattern

  private _privMSGMethod as PrivMSGCommand

  public PrivMSGMethod as PrivMSGCommand:
    get:
      return _privMSGMethod

  private _rawMSGMethod as RawMSGCommand

  public RawMSGMethod as RawMSGCommand:
    get:
      return _rawMSGMethod

  private _timerCommand as TimerCommand

  public TimerCommand as TimerCommand:
    get:
      return _timerCommand

  private _executionInterval as int

  public ExecutionInterval as int:
    get:
      return _executionInterval

  private _commandType as CommandType

  public CommandType as CommandType:
    get:
      return _commandType
  
  _messageName as string
  MessageName as string:
    get:
      return _messageName
  
  [property(PluginId)]
  _pluginIn as Guid
  
  public def constructor(names as List of string, syntaxPattern as regex, method as PrivMSGCommand):
    CommonSetup()
    _names.AddRange(names)
    _syntaxPattern = syntaxPattern
    _privMSGMethod = method
    _commandType = CommandType.PrivMSGCommand

  public def constructor(name as string, syntaxPattern as regex, method as RawMSGCommand):
    CommonSetup()
    Names.Add(name)
    _syntaxPattern = syntaxPattern
    _rawMSGMethod = method
    _commandType = CommandType.RawMSGCommand
  
  public def constructor(executionInterval as int, method as TimerCommand):
    CommonSetup()
    _executionInterval = executionInterval
    _timerCommand = method
    _commandType = CommandType.TimerCommand
  
  public def constructor(regexPattern as regex, method as PrivMSGCommand):
    CommonSetup()
    _privMSGMethod = method
    _commandType = CommandType.ComplexCommand
    _syntaxPattern = regexPattern
  
  public def constructor(messageName as string, method as RawMSGCommand):
    CommonSetup()
    _messageName = messageName
    _rawMSGMethod = method
    _commandType = CommandType.PubSubCommand
  
  public def CommonSetup():
    _names = List[of string]()