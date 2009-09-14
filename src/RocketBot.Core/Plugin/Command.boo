namespace RocketBot.Core

import System
import System.Collections.Generic
import System.Text.RegularExpressions

public callable PrivMSGCommand(message as IncomingMessage, displayDocs as bool) as void
public callable RawMSGCommand(message as IncomingMessage) as void
public callable TimerCommand(placeHolder as object) as void

public enum CommandType:

	RawMSGCommand

	PrivMSGCommand

	TimerCommand


public class CommandWrapper:

	
	#region properties
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

	
	#endregion
	
	public def constructor(names as (string), syntaxPattern as Regex, method as PrivMSGCommand):
		_names = List[of string](names)
		_syntaxPattern = syntaxPattern
		_privMSGMethod = method
		_commandType = CommandType.PrivMSGCommand

	public def constructor(name as string, syntaxPattern as Regex, method as RawMSGCommand):
		_names = List[of string]()
		Names.Add(name)
		_syntaxPattern = syntaxPattern
		_rawMSGMethod = method
		_commandType = CommandType.RawMSGCommand

	
	public def constructor(name as string, executionInterval as int, method as TimerCommand):
		_names = List[of string]()
		Names.Add(name)
		_executionInterval = executionInterval
		_timerCommand = method
		_commandType = CommandType.TimerCommand
	

