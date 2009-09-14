
namespace PredibotLib

import System
import System.Collections.Generic
import System.Text

public class CommandLogMessage:

	
	private _network as string

	public Network as string:
		get:
			return _network
		set:
			_network = value

	
	private _server as string

	public Server as string:
		get:
			return _server
		set:
			_server = value

	
	private _channel as string

	public Channel as string:
		get:
			return _channel
		set:
			_channel = value

	
	private _command as string

	public Command as string:
		get:
			return _command
		set:
			_command = value

	
	private _messageDate as date

	public MessageDate as date:
		get:
			return _messageDate
		set:
			_messageDate = value

	
	private _args as string

	public Args as string:
		get:
			return _args
		set:
			_args = value

	
	private _user as User

	public User as User:
		get:
			return _user
		set:
			_user = value

	
	public def constructor(network as string, server as string, channel as string, command as string, args as string, messageDate as date, user as User):
		Network = network
		Server = server
		Channel = channel
		Command = command
		Args = args
		MessageDate = messageDate
		User = user

	
	public static def CompareByDate(item1 as CommandLogMessage, item2 as CommandLogMessage) as int:
		
		return Comparer[of date].Default.Compare(item1.MessageDate, item2.MessageDate)
		
	

