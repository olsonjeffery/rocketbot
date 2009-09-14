namespace RocketBot.Core

import System
import System.Net.Sockets
import System.IO
import System.Threading
import System.Collections
import System.Collections.Generic

// Class to get information from the IRC Server
public class IrcConnection:

  
  public static def IsNickIdentifiedToServices(nick as string) as bool:
    
    
    whoisEOF as string = (((('318 ' + BotConfig.GetParameter('IRCNick')) + ' ') + nick) + ' :End of /WHOIS list.')
    
    nickIdString as string = (((('320 ' + BotConfig.GetParameter('IRCNick')) + ' ') + nick) + ' :is identified to services')
    
    isNickRegged = false
    
    
    
    
    
    SendWHOIS(nick)
    
    Thread.Sleep(500)
    
    inputLine = ''
    lock IrcConnection.backupQueue:
      while IrcConnection.backupQueue.Count != 0:
        inputLine = IrcConnection.backupQueue.Dequeue()
        
        Utilities.DebugOutput(('Backup Stream: ' + inputLine))
        
        if inputLine.Contains(nickIdString):
          
          isNickRegged = true
        elif inputLine.Contains(whoisEOF):
        
        
          Utilities.DebugOutput('Got WHOIS EOF!')
    
    
    return isNickRegged

  
  public static def SendWHOIS(nick as string):
    
    //IrcBot.writer.WriteLine("WHOIS :" + nick);
    //IrcBot.writer.Flush();
    IrcConnection.SendRawMessage(('WHOIS :' + nick))
    

  
  public static def SendPRIVMSG(destination as string, message as string):
    
    //IrcBot.writer.WriteLine("PRIVMSG " + destination +
    //        " :" + message);
    //IrcBot.writer.Flush();
    IrcConnection.SendRawMessage(((('PRIVMSG ' + destination) + ' :') + message))
    

  
  public static def SendQUIT(message as string):
    
    //IrcBot.writer.WriteLine("QUIT :" + message);
    //IrcBot.writer.Flush();
    IrcConnection.SendRawMessage(('QUIT :' + message))
    

  
  private static def SendRawMessage(message as string):
    
    IrcConnection.Writer.WriteLine(message)
    IrcConnection.Writer.Flush()
    

  
  #region IrcClient/Connection Properties
  
  #region Server
  // Irc Server to connect
  //public static string Server = "irc.df.lth.se";
  private _Server as string

  public Server as string:
    get:
      return _Server
    set:
      _Server = value

  #endregion
  
  #region Port
  // Irc Server's Port (6667 is default Port)
  //private static int Port = 6667;
  private _Port as int

  public Port as int:
    get:
      return _Port
    set:
      _Port = value

  #endregion
  
  #region User
  // User information defined in RFC 2812 (Internet Relay Chat: Client Protocol) is sent to irc Server
  //private static string User = "User CSharpBot 8 * :I'm a C# irc bot";
  private _User as string

  public User as string:
    get:
      return _User
    set:
      _User = value

  #endregion
  
  #region Nick
  // Bot's Nickname
  //private static string Nick = "BotNick";
  private _Nick as string

  public Nick as string:
    get:
      return _Nick
    set:
      // validation?
      _Nick = value

  #endregion
  
  #region Channel
  // Channel to join
  //private static string Channel = "#my_Channel";
  
  private _Channel as string

  public Channel as string:
    get:
      return _Channel
    set:
      
      // validations on Channel
      // prolly a regex to make sure
      // there is no whitespace and
      // that is starts with a #
      _Channel = value

  #endregion
  
  #region NickservPassword
  private _NickservPassword as string

  public NickservPassword as string:
    get:
      return _NickservPassword
    set:
      _NickservPassword = value

  #endregion
  
  #endregion
  
  // StreamWriter is declared here so that PingSender can access it
  private static _writer as StreamWriter

  private static _reader as StreamReader

  public static Writer as StreamWriter:
    get:
      return _writer

  public static Reader as StreamReader:
    get:
      return _reader

  public static backupQueue as Queue[of string]

  // another queue for unit testing purposes...
  // this will allow the bot to "issue bot commands" to itself
  // to exercise functionality
  public static testQueue as Queue[of string]

  
  
  private static irc as TcpClient

  public def constructor(ServerIn as string, PortIn as int, UserIn as string, NickIn as string, ChannelIn as string, NickservPasswordIn as string):
    Server = ServerIn
    Port = PortIn
    User = UserIn
    Nick = NickIn
    Channel = ChannelIn
    NickservPassword = NickservPasswordIn
    
    

  
  public def Connect():
    stream as NetworkStream
    //TcpClient irc;
    inputLine as string
    try:
      // Connection stuff
      
      // set up the tcp connection and streams
      // for the connection
      irc = TcpClient(Server, Port)
      stream = irc.GetStream()
      _reader = StreamReader(stream)
      _writer = StreamWriter(stream)
      
      // connecting to the server and passing it
      // username/nick info
      Writer.WriteLine(User)
      Writer.Flush()
      Writer.WriteLine(('Nick ' + Nick))
      Writer.Flush()
      // nickserv registration...
      if BotConfig.GetParameter('RegisterWithNickserv').ToString() == 'True':
        Writer.WriteLine(('PRIVMSG nickserv :identify ' + NickservPassword))
        Writer.Flush()
      
      // joining the channel the bot is watching
      Writer.WriteLine(('JOIN ' + Channel))
      Writer.Flush()
      // END CONNECTION STUFF
      
      
      
      // BREAK THIS OFF TO A SEPARATE METHOD
      
      // the backup queue contains a copy of the current
      // buffer which can be parsed by methods that would
      // like to use it (ie to get whois information)
      backupQueue = Queue[of string]()
      
      // Start PingSender thread
      ping = PingSender(Server)
      ping.Start()
      
      // START THE TIMER COMMAND HANDLER HERE
      
      
      
      
      // the main loop
      while true:
        while (inputLine = Reader.ReadLine()) is not null:
          
          // The "backup Queue" which is
          // used by some commands downstream to 
          // get information back from the IRC Server
          backupQueue.Enqueue(inputLine)
          
          // show raw irc output, if enabled in config
          ShowRawIRCOutput(inputLine)
          
          // here is where we parse a message to determine
          // if it is of any signifigance to the bot
          
          // Parse a message
          message = IncomingMessage(inputLine.ToString())
          
          //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          // the way that messages aprsed below needs to change
          // in line with the move towards the new plugin archetecture...
          // I want to split the message scrub up into basically two
          // categories... 
          //
          // Commands that operate on only PRIVMSG (ie "in channel" or
          // "user to user" messages) and commands that are checked
          // against an entire RAW Message (right now the only thing
          // I have that fits that criteria are topic changes).
          //
          // All commands are based on privmsg scrubbing, as well
          // as irc message logging and weburl summarizing.
          //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          
          // this is a quick hack to enable privmsg communication..
          // ie if the "channel" for this message is the bot's name,
          // that means it's a privmsg, so the channel for reply
          // should be changed to the sender's nick
          if message.Channel == BotConfig.GetParameter('IRCNick'):
            message.Channel = message.Nick
          
          // PRIV MSG COMMAND
          // if the message was parsed as a command, execute it
          if (message.MessageType == 1) or (message.MessageType == 3):
            PrivMSGRunner.ParseCommand(message)
          
          // RAW MSG PARSING
          RawMSGRunner.ParseMessage(message)
            
        
        // Close all streams
        Writer.Close()
        Reader.Close()
        irc.Close()
    except e as Exception:
      // Show the exception, sleep for a while and try to establish a new connection to irc Server
      Console.WriteLine((Utilities.TimeStamp() + e.ToString()))
      Thread.Sleep(5000)
      //string[] argv = { };
      Connect()
  
  public static def GracefulExit():
    
    // need to put a proper log message in here
    
    Utilities.DebugOutput('Attempting to shutdown gracefully')
    
    SendQUIT('Arf, Arf!')
    
    // just to give the quit message time to get out of the door before closing
    // the tcp connection
    Thread.Sleep(1000)
    irc.Close()
    
    Environment.Exit(0)
    

  
  public def ShowRawIRCOutput(output as string):
    
    // print raw output from the server, if configured
    if BotConfig.GetParameter('RawIRCOutput') == 'True':
      Utilities.DebugOutput(output)
    
  




/*
* Class that sends PING to irc Server every 15 seconds
*/

internal class PingSender:

  private static Ping = 'PING :'

  private static Server as string

  private pingSender as Thread

  // Empty constructor makes instance of Thread
  
  public def constructor(server as string):
    PingSender.Server = server
    pingSender = Thread(ThreadStart(self.Run))

  
  
  // Starts the thread
  public def Start():
    pingSender.Start()

  
  // Send PING to irc Server every 15 seconds
  public def Run():
    while true:
      IrcConnection.Writer.WriteLine((PingSender.Ping + PingSender.Server))
      IrcConnection.Writer.Flush()
      Thread.Sleep((Int16.Parse(BotConfig.GetParameter('PingPongInterval')) * 1000))
  

