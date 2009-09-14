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
import System.Xml


public class WeatherData:

  
  public HourlyTemp as string

  public ApparentTemp as string

  
  public CloudCoverage as string

  public RelativeHumidity as string

  public PrecipPercentage as string

  
  public WindSpeed as string
  
  


public class NdfdXMLParser:

  
  // http://www.nws.noaa.gov/forecasts/xml/
  public static def ParseWeatherXML(xmlWeather as string) as WeatherData:
    try:
      DamnWeatherData = WeatherData()
      xmlDoc = XmlDocument()
      
      // load XML data into a tree
      xmlDoc.LoadXml(xmlWeather)
      
      // locate dwml/data/time-layout nodes. There should be three of them: 
      //      - next week nighttime temperatures (lows)
      //      - next week daytime temperatures (highs)
      //      - next week cloud data
      
      // Find roots nodes for temperature and cloud data
      hourlyTempNode as XmlNode = xmlDoc.SelectSingleNode('/dwml/data/parameters/temperature[@type=\'hourly\']')
      apparentTempNode as XmlNode = xmlDoc.SelectSingleNode('/dwml/data/parameters/temperature[@type=\'apparent\']')
      cloudCoverageNode as XmlNode = xmlDoc.SelectSingleNode('/dwml/data/parameters/cloud-amount[@type=\'total\']')
      humidityNode as XmlNode = xmlDoc.SelectSingleNode('/dwml/data/parameters/humidity[@type=\'relative\']')
      precipNode as XmlNode = xmlDoc.SelectSingleNode('/dwml/data/parameters/probability-of-precipitation[@type=\'12 hour\']')
      windSpeedNode as XmlNode = xmlDoc.SelectSingleNode('/dwml/data/parameters/wind-speed[@type=\'sustained\']')
      
      //XmlNodeList lowTempNodes = wtLowTemp.nodeData.SelectNodes("value");
      //XmlNodeList highTempNodes = wtHighTemp.nodeData.SelectNodes("value");
      hourlyTempValueNodes as XmlNodeList = hourlyTempNode.SelectNodes('value')
      apparentTempValueNodes as XmlNodeList = apparentTempNode.SelectNodes('value')
      cloudCoverageValueNodes as XmlNodeList = cloudCoverageNode.SelectNodes('value')
      humidityValueNodes as XmlNodeList = humidityNode.SelectNodes('value')
      precipValueNodes as XmlNodeList = precipNode.SelectNodes('value')
      windSpeedValueNodes as XmlNodeList = windSpeedNode.SelectNodes('value')
      //DamnWeatherData.LowTempF = lowTempNodes[0].ToString().Trim();
      //DamnWeatherData.HighTempF = highTempNodes[0].ToString().Trim();
      DamnWeatherData.HourlyTemp = hourlyTempValueNodes[0].InnerText.Trim()
      DamnWeatherData.ApparentTemp = apparentTempValueNodes[0].InnerText.Trim()
      DamnWeatherData.CloudCoverage = cloudCoverageValueNodes[0].InnerText.Trim()
      DamnWeatherData.RelativeHumidity = humidityValueNodes[0].InnerText.Trim()
      DamnWeatherData.PrecipPercentage = precipValueNodes[0].InnerText.Trim()
      DamnWeatherData.WindSpeed = windSpeedValueNodes[0].InnerText.Trim()
      
      return DamnWeatherData
    except e as Exception:
      Console.WriteLine(('PARSE EXCPETION: ' + e.ToString()))
      return null
  

