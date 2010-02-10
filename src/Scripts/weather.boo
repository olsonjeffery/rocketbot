namespace RocketBot.Scripts

import System
import System.Xml
import System.Text.RegularExpressions
import System.Net
import System.IO
import System.Text
import System.Web
import RocketBot.Core
import HtmlAgilityPack
import System.Web.Services.Protocols

plugin WeatherPlugin:
  name "weather"
  version "0.2"
  author "pfox"
  desc "gets weather information for a 5-digit ZIP code (US based)"
  
  docs weather:
    """
Documentation for the \'weather\' command:
Synonyms: none
Syntax: weather <location>
Alternative Syntax: none
Parameters: location: a zip code or city, state/country combination
Purpose: Provides current weather information for the supplied location.
    """
  
  bot_command weather:
    if message.Args is null or string.Empty.Equals(message.Args):
      IrcConnection.SendPRIVMSG(message.Channel, "How about you give me a location to look up instead of wasting my time?")
      return
    url = String.Format('http://www.google.com/ig/api?weather={0}', message.Args)
    url = url.Replace(" ", '%20')
    print url
    doc = HtmlDocument()
    doc.Load(GetStreamFromUrl(url))
    
    if doc.DocumentNode.SelectSingleNode("xml_api_reply/weather/problem_cause") is not null:
      IrcConnection.SendPRIVMSG(message.Channel, "Sorry, google doesn't have weather data for '"+message.Args+"'")
    else:
      locationName = Utilities.HtmlDecode(doc.DocumentNode.SelectSingleNode("xml_api_reply/weather/forecast_information/city").Attributes["data"].Value)
      timeOfMeasurement = doc.DocumentNode.SelectSingleNode("xml_api_reply/weather/forecast_information/current_date_time").Attributes["data"].Value
      condition = doc.DocumentNode.SelectSingleNode("xml_api_reply/weather/current_conditions/condition").Attributes["data"].Value
      tempF = doc.DocumentNode.SelectSingleNode("xml_api_reply/weather/current_conditions/temp_f").Attributes["data"].Value
      tempC = doc.DocumentNode.SelectSingleNode("xml_api_reply/weather/current_conditions/temp_c").Attributes["data"].Value
      humidity = doc.DocumentNode.SelectSingleNode("xml_api_reply/weather/current_conditions/humidity").Attributes["data"].Value
      winds = doc.DocumentNode.SelectSingleNode("xml_api_reply/weather/current_conditions/wind_condition").Attributes["data"].Value
      
      IrcConnection.SendPRIVMSG(message.Channel, "Weather for "+locationName+" at "+timeOfMeasurement)
      IrcConnection.SendPRIVMSG(message.Channel, "Condition: "+condition + ", "+tempF+"F ("+tempC+"C)")
      IrcConnection.SendPRIVMSG(message.Channel, humidity +", "+ winds)
