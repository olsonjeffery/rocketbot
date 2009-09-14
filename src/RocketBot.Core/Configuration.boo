
namespace RocketBot.Core

import System
import System.Net
import System.Net.Sockets
import System.IO
import System.Threading
import System.Data
import System.Collections
import System.Collections.Generic
import System.Text.RegularExpressions

public final class BotConfig:

	
	// this is the actual config, held in a 
	// datarow. yip yip yip!
	private static config as DataRow = null

	
	
	
	private def constructor():
		pass
		
		// yeeeeah
		

	
	
	public static def Initialize(path as string, configPiece as string):
		
		// i suppose its fair to say that this is a pretty kludgey
		// way to implement the whole config affair (ie via a datarow
		// in a handjammed config file)... but it appears that
		// System.Configuration isn't implemented fully/properly(?)
		// in mono (judging by all the stubbed out methods), so this
		// is how it's gonna be done...
		ds = DataSet()
		try:
			
			ds.ReadXml(path)
			config = ds.Tables[configPiece].Rows[0]
		
		except e as Exception:
			
			// log call here
			Console.WriteLine(('Failure to initialize Configuration: ' + e.ToString()))
		
		

	
	public static def Initialize():
		
		/*
            bool haveConfigFilePath = false;

            // get some info
            string[] OS = (System.Environment.OSVersion.ToString().Trim()).Split(' ');


            // useful env vars:
            // windows: APPDATA, User, 
            IDictionary envVars = System.Environment.GetEnvironmentVariables();
            */
		
		
		path = 'RocketBot.config.xml'
		
		Initialize(((System.Environment.CurrentDirectory.ToString() + System.IO.Path.DirectorySeparatorChar.ToString()) + path), 'RocketBotConfiguration')

	
	
	public static def GetParameter(param as string) as string:
		
		if (config[param].ToString().Trim() is null) or (config[param].ToString().Trim() == ''):
			
			raise Exception('Non-existent/invalid configuration parameter selected')
		else:
			
			return config[param].ToString().Trim()
	
	

