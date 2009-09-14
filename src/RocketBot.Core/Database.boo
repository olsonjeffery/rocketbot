
namespace PredibotLib

import System
import System.Net
import System.Net.Sockets
import System.IO
import System.Threading
import System.Data
import System.Collections
import System.Collections.Generic
import System.Text.RegularExpressions
import Db4objects.Db4o
import Db4objects.Db4o.Query


public callable DBQueryEvaluator(input as object) as bool

public static class Database:

	
	
	
	private static IsInitialized as bool

	private static db as IObjectContainer

	public static DBConn as IObjectContainer

	
	public static DB as IObjectContainer:
		static get:
			return db

	
	
	public static def CheckForInitialization():
		if IsInitialized == true:
			Utilities.DebugOutput('DB is initialized, closing...')
			//throw new Exception("Attempt to Initialize an already initialized DB. Tsk, tsk!");
			CloseDBConnection()
		else:
			Utilities.DebugOutput('DB is not initialized...')

	
	#region User methods
	// User stuff
	
	
	
	#endregion
	
	#region IRCLogMessage methods
	// IRCLogMessage stuff
	
	
	
	/*
        public static List<IRCLogMessage> GetAllIRCLogMessages()
        {

            lock (typeof(Database))
            {

                

                IList<IRCLogMessage> messagesTemp = db.Query<IRCLogMessage>(delegate(IRCLogMessage ircMessage)
                {
                    
                    return true;

                });

                List<IRCLogMessage> ircMessages = new List<IRCLogMessage>(messagesTemp);

                Utilities.DebugOutput("size of ircMessages in get all: " + ircMessages.Count.ToString());

                
                return ircMessages;
            }

        }
         * */
	
	#endregion
	
	#region WebURL methods
	// WebURL stuff
	public static def CreateNewWebURL(message as IncomingMessage, url as string, description as string):
		
		lock typeof(Database):
			Utilities.DebugOutput('Creating new WebURL...')
			webURL = WebURL(message.User, url, message.MessageTime, description)
			
			db.Set(webURL)
			
			db.Commit()
		

	
	public static def GetFiveMostRecentWebURLs() as List[of WebURL]:
		
		lock typeof(Database):
			
			query as IQuery = db.Query()
			query.Constrain(typeof(WebURL))
			query.Descend('PostDate').OrderDescending()
			
			results as IObjectSet = query.Execute()
			
			Utilities.DebugOutput(('Size of webURLs results: ' + results.Size().ToString()))
			
			webURLs as List[of WebURL] = List[of WebURL]()
			
			objectSetSize as int = results.Size()
			
			// iterate through the list, filling it up.. ensuring to not
			// go furhter than five elements, but stop if the ObjectSet is
			// less than five elements in size
			ctr = 0
			goto converterGeneratedName1
			while true:
				ctr += 1
				:converterGeneratedName1
				break  unless ((ctr < objectSetSize) and (ctr < 5))
				
				webURLs.Add(cast(WebURL, results[ctr]))
			
			
			
			
			return webURLs

	
	public static def GetGiveMostRecentWebURLsByNick(nick as string) as List[of WebURL]:
		
		lock typeof(Database):
			/* need to do a native query
                IQuery query = db.Query();
                query.Constrain(typeof(WebURL));
                query.Descend("Nick").Constrain(nick);
                query.Descend("PostDate").OrderDescending();

                IObjectSet results = query.Execute();
                */
			
			
			webURLsTemp as IList[of WebURL] = db.Query({ webURL as WebURL | return (webURL.User.Nick == nick) })
			
			
			
			//Utilities.DebugOutput("Size of webURLs results: " + results.Size().ToString());
			
			webURLs as List[of WebURL] = List[of WebURL](webURLsTemp)
			
			webURLs.Sort(WebURL.CompareByDate)
			webURLs.Reverse()
			
			objectSetSize as int = webURLs.Count
			
			returnURLs as List[of WebURL] = List[of WebURL]()
			
			// iterate through the list, filling it up.. ensuring to not
			// go furhter than five elements, but stop if the ObjectSet is
			// less than five elements in size
			ctr = 0
			goto converterGeneratedName2
			while true:
				ctr += 1
				:converterGeneratedName2
				break  unless ((ctr < objectSetSize) and (ctr < 5))
				
				returnURLs.Add(webURLs[ctr])
			
			
			
			
			return returnURLs
		

	#endregion
	
	#region Bandname methods
	
	public static def CreateNewBandName(message as IncomingMessage):
		
		lock typeof(Database):
			
			if DoesBandNameExist(message.Args.Trim()):
				// band name already exists
				return 
			elif User.DoesUserExistByNick(message.Args.Trim()):
			
				
				// cannot name a band after a user
				return 
			
			// if we make it here the bandname is fair game!
			user as User = message.User
			band = BandName(message.Args, user, DateTime.Now)
			
			db.Set(band)
			db.Commit()
			return 
		
		

	
	public static def DeleteBandName(bandName as string):
		
		lock typeof(Database):
			
			if not DoesBandNameExist(bandName):
				return 
			
			band as BandName = GetBandNameByName(bandName)
			db.Delete(band)
		
		

	
	public static def DoesBandNameExist(bandName as string) as bool:
		
		lock typeof(Database):
			
			bands as IList[of BandName] = db.Query({ band as BandName | return (band.Name == bandName) })
			
			
			
			return (bands.Count > 0)
		
		
		

	
	public static def GetFiveMostRecentBandNamesByNick(nick as string) as List[of BandName]:
		
		lock typeof(Database):
			
			returnBands as List[of BandName] = List[of BandName]()
			
			bandsTemp as IList[of BandName] = db.Query({ band as BandName | return (band.Owner.Nick == nick) })
			
			
			
			bandsList as List[of BandName] = List[of BandName](bandsTemp)
			
			bandsList.Sort(BandName.CompareByDate)
			bandsList.Reverse()
			
			ctr = 0
			goto converterGeneratedName3
			while true:
				ctr += 1
				:converterGeneratedName3
				break  unless ((ctr < bandsList.Count) and (ctr < 5))
				
				returnBands.Add(bandsList[ctr])
			
			
			return returnBands
		
		

	
	public static def GetFiveMostRecentBandNames() as List[of BandName]:
		
		lock typeof(Database):
			
			returnBands as List[of BandName] = List[of BandName]()
			
			bandsTemp as IList[of BandName] = db.Query({ band as BandName | return true })
			
			
			
			bandsList as List[of BandName] = List[of BandName](bandsTemp)
			
			bandsList.Sort(BandName.CompareByDate)
			bandsList.Reverse()
			
			ctr = 0
			goto converterGeneratedName4
			while true:
				ctr += 1
				:converterGeneratedName4
				break  unless ((ctr < bandsList.Count) and (ctr < 5))
				
				returnBands.Add(bandsList[ctr])
			
			
			return returnBands
		
		

	
	public static def GetBandNameByName(name as string) as BandName:
		lock typeof(Database):
			bands as IList[of BandName] = db.Query({ band as BandName | return (band.Name == name) })
			
			
			
			// we shouldn't be storing more than one bandname
			// .. in fact its built into the CreateBandName() 
			// method, so we have to assume that is the case..
			// so we're just going to return the first, if
			// there was one.. if count == 0, we're return a 
			// "null" bandname
			if bands.Count == 0:
				
				return BandName('.', User('null', DateTime.Now), DateTime.Now)
				
				
			
			return bands[0]
		

	
	public static def GetBandNamesCount() as int:
		
		lock typeof(Database):
			
			bands as IList[of BandName] = db.Query({ band as BandName | return true })
			
			
			
			return bands.Count
		
		

	
	#endregion
	
	#region Topic methods
	
	public static def CreateNewTopic(message as IncomingMessage):
		lock typeof(Database):
			
			Utilities.DebugOutput((('STORING TOPIC FROM USER \'' + message.User) + '\''))
			topic = ChannelTopic(message.User, message.Message, DateTime.Now, message.Channel)
			
			db.Set(topic)
			db.Commit()
		

	
	public static def GetFiveMostRecentChannelTopics(channel as string) as List[of ChannelTopic]:
		lock typeof(Database):
			
			topicsTemp as IList[of ChannelTopic] = db.Query({ topic as ChannelTopic | return (topic.Channel == channel) })
			
			
			
			topicsList as List[of ChannelTopic] = List[of ChannelTopic](topicsTemp)
			
			topicsList.Sort(ChannelTopic.CompareByDate)
			topicsList.Reverse()
			
			returnTopics as List[of ChannelTopic] = List[of ChannelTopic]()
			
			ctr = 0
			goto converterGeneratedName5
			while true:
				ctr += 1
				:converterGeneratedName5
				break  unless ((ctr < topicsList.Count) and (ctr < 5))
				
				returnTopics.Add(topicsList[ctr])
			
			
			return returnTopics
		

	
	public static def GetFiveMostRecentChannelTopicsByNick(channel as string, nick as string) as List[of ChannelTopic]:
		lock typeof(Database):
			topicsTemp as IList[of ChannelTopic] = db.Query({ topic as ChannelTopic | return ((topic.User.Nick == nick) and (topic.Channel == channel)) })
			
			
			
			topicsList as List[of ChannelTopic] = List[of ChannelTopic](topicsTemp)
			
			topicsList.Sort(ChannelTopic.CompareByDate)
			topicsList.Reverse()
			
			returnTopics as List[of ChannelTopic] = List[of ChannelTopic]()
			
			ctr = 0
			goto converterGeneratedName6
			while true:
				ctr += 1
				:converterGeneratedName6
				break  unless ((ctr < topicsList.Count) and (ctr < 5))
				
				returnTopics.Add(topicsList[ctr])
			
			
			return returnTopics
		

	
	#endregion
	
	#region Database setup methods
	// Database connection open/close stuff
	
	
	
	public static def InitializeDBConnection():
		
		InitializeDBConnection(PredibotLib.Configuration.GetParameter('DatabaseFileName'))
		

	
	public static def InitializeDBConnection(path as string):
		
		
		//Utilities.DebugOutput("Checking if DB is already initialized...");
		Utilities.DebugOutput('Checking for Initialization...')
		CheckForInitialization()
		IsInitialized = true
		
		
		// file up the db... if no file exists, it creates a new one
		
		lock typeof(Database):
			
			Utilities.DebugOutput('Opening DB Connection...')
			db = Db4oFactory.OpenFile(path)
			DBConn = db

	
	public static def CloseDBConnection():
		
		lock typeof(Database):
			
			Utilities.DebugOutput('Attempting to close DB')
			
			if IsInitialized == false:
				Utilities.DebugOutput('Db is already closed, aborting...')
				return 
				
			
			Utilities.DebugOutput('Closing DB...')
			db.Close()
			IsInitialized = false

	
	#endregion
	
	#region TEST METHODS FOR DATABASE FUNCTIONALITY
	public static def ThreadLockTest1(message as IncomingMessage):
		
		lock typeof(Database):
			
			IrcConnection.SendPRIVMSG(message.Channel, 'Thread 1 before sleep')
			Thread.Sleep(2000)
			IrcConnection.SendPRIVMSG(message.Channel, 'Thread 1 after sleep')
		
		

	
	public static def ThreadLockTest2(message as IncomingMessage):
		
		lock typeof(Database):
			
			IrcConnection.SendPRIVMSG(message.Channel, 'Thread 2 message')
		
		
	#endregion
	
	
	

