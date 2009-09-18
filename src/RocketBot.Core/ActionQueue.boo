namespace RocketBot.Core

import System
import System.IO
import System.Threading
import System.Data
import System.Collections
import System.Collections.Generic

public class ActionQueue:

  
  private static _queue as Queue[of ActionItem]

  
  public def constructor():
    
    _queue = Queue[of ActionItem]()
    

  
  public static def EnqueueItem(item as ActionItem):
    
    _queue.Enqueue(item)
    DequeueItem()

  
  public static def DequeueItem():
    
    item as ActionItem = _queue.Dequeue()
    
    // ugly, but simple. teehee.
    //
    // make a dummy thread so we can re-use that thread ref
    // down the road
    thread = Thread def():
      pass

    if item.CommandType == CommandType.PrivMSGCommand or item.CommandType == CommandType.ComplexCommand:
      thread = Thread({ item.PrivMSGCommandMethod(item.Message, item.Message.DisplayDocs) })
    elif item.CommandType == CommandType.RawMSGCommand:
      thread = Thread({ item.RawMSGCommandMethod(item.Message) })
    
    Utilities.DebugOutput('Spinning off new thread...')
    thread.Start()
    

  
  public static def Initialize():
    
    _queue = Queue[of ActionItem]()
    
  
  


public class ActionItem:

  
  private _message as IncomingMessage

  public Message as IncomingMessage:
    get:
      return _message
    set:
      _message = value

  
  private _privMSGCommandMethod as PrivMSGCommand

  public PrivMSGCommandMethod as PrivMSGCommand:
    get:
      return _privMSGCommandMethod
    set:
      _privMSGCommandMethod = value

  private _rawMSGCommandMethod as RawMSGCommand

  public RawMSGCommandMethod as RawMSGCommand:
    get:
      return _rawMSGCommandMethod
    set:
      _rawMSGCommandMethod = value

  private _commandType as CommandType

  public CommandType as CommandType:
    get:
      return _commandType

  
  public def constructor(message as IncomingMessage, commandMethod as PrivMSGCommand):
    
    Message = message
    PrivMSGCommandMethod = commandMethod
    _commandType = CommandType.PrivMSGCommand
    

  public def constructor(message as IncomingMessage, commandMethod as RawMSGCommand):
    Message = message
    RawMSGCommandMethod = commandMethod
    _commandType = CommandType.RawMSGCommand
  


