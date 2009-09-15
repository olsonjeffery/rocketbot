namespace RocketBot.Scripts

import System
import System.Xml
import System.Text.RegularExpressions
import System.Net
import System.IO
import System.Text
import RocketBot.Core

plugin WeatherPlugin:
  name "weather"
  version "0.1"
  author "pfox"
  desc "gets weather information for a 5-digit ZIP code (US based)"
  bot_command '(^(?<command>weather)\\s+(?<args>[0-9]{5})$|^(?<command>weather) for (?<args>[0-9]{5})$)', weather:
    // if this is true, then instead of running the command, we just output
    // the documentation for this command to the requesting user via privmsg
    if displayDocs:
      // display syntax stuff here
      IrcConnection.SendPRIVMSG(message.Nick, 'Documentation for the \'weather\' command:')
      IrcConnection.SendPRIVMSG(message.Nick, 'Synonyms: none')
      IrcConnection.SendPRIVMSG(message.Nick, 'Syntax: weather <zip>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Alternative Syntax: weather for <zip>')
      IrcConnection.SendPRIVMSG(message.Nick, 'Parameters: zip: a five digit numerical zip code')
      IrcConnection.SendPRIVMSG(message.Nick, 'Purpose: Provides current weather information for the supplied zip code.')
      return 
    
    
    // need to parse out the zip..
    // parse passed in zip to string
    
    // bring the methods under the "new" command parse regime?
    match as Match = Regex('(?<zip>[0-9]{5})').Match(message.Args.Trim())
    
    
    Utilities.DebugOutput(('Pre-parse ZIP: ' + message.Args))
    zip = ''
    if match.Success:
      
      zip = match.Groups['zip'].Value
    else:
      
      IrcConnection.SendPRIVMSG(message.Channel, 'Bad ZIP code format, use only five-letter zip codes to represent a location, please. Non-US people, you\'re out of luck.')
      return 
    
    
    // need to convert the zip to long/lat
    // http://www.zipinfo.com/cgi-local/zipsrch.exe?ll=ll&zip=98388&Go=Go
    // ripped from the web summary command
    sb = StringBuilder()
    buf as (byte) = array(byte, 8192)
    resStream as Stream = Stream.Null
    
    try:
      
      //Console.WriteLine(Utilities.TimeStamp() + "loading table...");
      request = cast(HttpWebRequest, WebRequest.Create((('http://www.zipinfo.com/cgi-local/zipsrch.exe?ll=ll&zip=' + zip.ToString()) + '&Go=Go')))
      
      response = cast(HttpWebResponse, request.GetResponse())
      
      resStream = response.GetResponseStream()
      
      tempString as string = null
      count = 0
      
      while true:
        // fill the buffer with data
        count = resStream.Read(buf, 0, buf.Length)
        
        // make sure we read some data
        if count != 0:
          // translate from bytes to ASCII text
          tempString = Encoding.ASCII.GetString(buf, 0, count)
          
          // continue building the string
          //char[] trimChars = {'\n'};
          sb.Append(tempString)
        break  unless (count > 0)
      // any more data to read?
      //Console.WriteLine(Utilities.TimeStamp() + "before parse attempt");
      
      // ok we now have a shitload of ugly html...
      // we want split[2] ...
      splitTokenOne as (string) = (zip,)
      splitStrings as (string) = sb.ToString().Split(splitTokenOne, StringSplitOptions.None)
      splitString as string = splitStrings[2].ToString()
      
      // quick grab here to get the info so we can parse out the city, state
      cityStateString as string = splitStrings[1].ToString()
      
      splitTokenTwo as (string) = ('</font></td></tr></table>',)
      splitStrings = splitString.Split(splitTokenTwo, StringSplitOptions.None)
      splitString = splitStrings[0].ToString()
      splitString = splitString.Replace('</font></td><td align=center>', ' ')
      splitString = splitString.Substring(1, (splitString.Length - 1))
      splitTokenThree as (string) = (' ',)
      latLongStrings as (string) = splitString.Split(splitTokenThree, StringSplitOptions.None)
      latLongs as (decimal) = (decimal.Parse(latLongStrings[0]), decimal.Parse(('-' + latLongStrings[1])))
      
      cityStateSplitTokenOne as (string) = ('(West)',)
      cityStateSplits as (string) = cityStateString.Split(cityStateSplitTokenOne, StringSplitOptions.None)
      cityStateString = cityStateSplits[1].ToString()
      cityStateString = cityStateString.Replace('</th></tr><tr><td align=center>', '')
      cityStateString = cityStateString.Replace('</font></td><td align=center>', '')
      
      cityStateSplitsTwo as (string) = (cityStateString.Substring(0, (cityStateString.Length - 2)).ToString(), cityStateString.Substring((cityStateString.Length - 2), 2).ToString())
      //Formatting.WriteToChannel(message.Channel,"Lat/Long for "+cityStateSplitsTwo[0]+", "+cityStateSplitsTwo[1]+": "+latLongs[0].ToString()+", "+latLongs[1].ToString());
      
      // feed to weather service
      weather = ndfdXML()
      weatherParams = weatherParametersType()
      
      //weatherParams.wx = true;    // Weather
      //weatherParams.maxt = true;  // High temp
      //weatherParams.mint = true;  // Low temp
      weatherParams.temp = true
      // 3 hour temperature
      weatherParams.appt = true
      // Apparent temp
      weatherParams.rh = true
      // relative humidity
      weatherParams.pop12 = true
      // 12-Hour chance of Precip
      weatherParams.wspd = true
      // wind speed
      weatherParams.sky = true
      // cloud coverage
      rawXML as string = weather.NDFDgen(latLongs[0], latLongs[1], 'time-series', System.DateTime.Now, System.DateTime.Now.AddDays(1), weatherParams)
      
      // remove tabs and newlines
      // which should leave us with just the mark-up..
      //Console.WriteLine(rawXML);
      
      wd as WeatherData = NdfdXMLParser.ParseWeatherXML(rawXML)
      
      windSpeedMPH as single = (single.Parse(wd.WindSpeed) * cast(single, 1.15077945))
      windSpeedMPH.ToString('N2')
      
      IrcConnection.SendPRIVMSG(message.Channel, (((((('Weather for ' + cityStateSplitsTwo[0]) + ', ') + cityStateSplitsTwo[1]) + ' (') + zip) + '):'))
      IrcConnection.SendPRIVMSG(message.Channel, (((((('Temperature: ' + wd.HourlyTemp) + 'F (Feels like ') + wd.ApparentTemp) + 'F) Humidity: ') + wd.RelativeHumidity) + '% '))
      IrcConnection.SendPRIVMSG(message.Channel, (((((('Cloud Coverage: ' + wd.CloudCoverage) + '% Chance of Precipitation: ') + wd.PrecipPercentage) + '% Wind Speed: ') + windSpeedMPH.ToString('N1')) + ' MPH'))
    
    
    except e as Exception:
      
      Console.WriteLine(('Ruh roh! Exception: ' + e.ToString()))
      IrcConnection.SendPRIVMSG(message.Channel, 'Something is b0rked with the weather fetch attempt.')

//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:2.0.50727.42
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------


// 
// This source code was auto-generated by wsdl, Version=2.0.50727.312.
// 


[System.CodeDom.Compiler.GeneratedCodeAttribute('wsdl', '2.0.50727.312')]
[System.Diagnostics.DebuggerStepThroughAttribute]
[System.ComponentModel.DesignerCategoryAttribute('code')]
[System.Web.Services.WebServiceBindingAttribute(Name: 'ndfdXMLBinding', Namespace: 'http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl')]
partial public class ndfdXML(System.Web.Services.Protocols.SoapHttpClientProtocol):

  
  private NDFDgenOperationCompleted as System.Threading.SendOrPostCallback

  
  private NDFDgenByDayOperationCompleted as System.Threading.SendOrPostCallback

  
  public def constructor():
    self.Url = 'http://www.weather.gov/forecasts/xml/SOAP_server/ndfdXMLserver.php'

  
  public event NDFDgenCompleted as NDFDgenCompletedEventHandler

  
  public event NDFDgenByDayCompleted as NDFDgenByDayCompletedEventHandler

  
  [System.Web.Services.Protocols.SoapRpcMethodAttribute('http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl#NDFDgen', RequestNamespace: 'http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl', ResponseNamespace: 'http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl')]
  public def NDFDgen(latitude as decimal, longitude as decimal, product as string, startTime as date, endTime as date, weatherParameters as weatherParametersType) as string:
    results as (object) = self.Invoke('NDFDgen', (of object: latitude, longitude, product, startTime, endTime, weatherParameters))
    return cast(string, results[0])

  
  public def BeginNDFDgen(latitude as decimal, longitude as decimal, product as string, startTime as date, endTime as date, weatherParameters as weatherParametersType, callback as System.AsyncCallback, asyncState as object) as System.IAsyncResult:
    return self.BeginInvoke('NDFDgen', (of object: latitude, longitude, product, startTime, endTime, weatherParameters), callback, asyncState)

  
  public def EndNDFDgen(asyncResult as System.IAsyncResult) as string:
    results as (object) = self.EndInvoke(asyncResult)
    return cast(string, results[0])

  
  public def NDFDgenAsync(latitude as decimal, longitude as decimal, product as string, startTime as date, endTime as date, weatherParameters as weatherParametersType):
    self.NDFDgenAsync(latitude, longitude, product, startTime, endTime, weatherParameters, null)

  
  public def NDFDgenAsync(latitude as decimal, longitude as decimal, product as string, startTime as date, endTime as date, weatherParameters as weatherParametersType, userState as object):
    if self.NDFDgenOperationCompleted is null:
      self.NDFDgenOperationCompleted = System.Threading.SendOrPostCallback(self.OnNDFDgenOperationCompleted)
    self.InvokeAsync('NDFDgen', (of object: latitude, longitude, product, startTime, endTime, weatherParameters), self.NDFDgenOperationCompleted, userState)

  
  private def OnNDFDgenOperationCompleted(arg as object):
    if self.NDFDgenCompleted is not null:
      invokeArgs = cast(System.Web.Services.Protocols.InvokeCompletedEventArgs, arg)
      self.NDFDgenCompleted(self, NDFDgenCompletedEventArgs(invokeArgs.Results, invokeArgs.Error, invokeArgs.Cancelled, invokeArgs.UserState))

  
  [System.Web.Services.Protocols.SoapRpcMethodAttribute('http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl#NDFDgenByDay', RequestNamespace: 'http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl', ResponseNamespace: 'http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl')]
  public def NDFDgenByDay(latitude as decimal, longitude as decimal, [System.Xml.Serialization.SoapElementAttribute(DataType: 'date')] startDate as date, [System.Xml.Serialization.SoapElementAttribute(DataType: 'integer')] numDays as string, format as string) as string:
    results as (object) = self.Invoke('NDFDgenByDay', (of object: latitude, longitude, startDate, numDays, format))
    return cast(string, results[0])

  
  public def BeginNDFDgenByDay(latitude as decimal, longitude as decimal, startDate as date, numDays as string, format as string, callback as System.AsyncCallback, asyncState as object) as System.IAsyncResult:
    return self.BeginInvoke('NDFDgenByDay', (of object: latitude, longitude, startDate, numDays, format), callback, asyncState)

  
  public def EndNDFDgenByDay(asyncResult as System.IAsyncResult) as string:
    results as (object) = self.EndInvoke(asyncResult)
    return cast(string, results[0])

  
  public def NDFDgenByDayAsync(latitude as decimal, longitude as decimal, startDate as date, numDays as string, format as string):
    self.NDFDgenByDayAsync(latitude, longitude, startDate, numDays, format, null)

  
  public def NDFDgenByDayAsync(latitude as decimal, longitude as decimal, startDate as date, numDays as string, format as string, userState as object):
    if self.NDFDgenByDayOperationCompleted is null:
      self.NDFDgenByDayOperationCompleted = System.Threading.SendOrPostCallback(self.OnNDFDgenByDayOperationCompleted)
    self.InvokeAsync('NDFDgenByDay', (of object: latitude, longitude, startDate, numDays, format), self.NDFDgenByDayOperationCompleted, userState)

  
  private def OnNDFDgenByDayOperationCompleted(arg as object):
    if self.NDFDgenByDayCompleted is not null:
      invokeArgs = cast(System.Web.Services.Protocols.InvokeCompletedEventArgs, arg)
      self.NDFDgenByDayCompleted(self, NDFDgenByDayCompletedEventArgs(invokeArgs.Results, invokeArgs.Error, invokeArgs.Cancelled, invokeArgs.UserState))

  
  public def CancelAsync(userState as object):
    super.CancelAsync(userState)


[System.CodeDom.Compiler.GeneratedCodeAttribute('wsdl', '2.0.50727.312')]
[System.SerializableAttribute]
[System.Diagnostics.DebuggerStepThroughAttribute]
[System.ComponentModel.DesignerCategoryAttribute('code')]
[System.Xml.Serialization.SoapTypeAttribute(Namespace: 'http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl')]
partial public class weatherParametersType:

  
  private maxtField as bool

  
  private mintField as bool

  
  private tempField as bool

  
  private dewField as bool

  
  private pop12Field as bool

  
  private qpfField as bool

  
  private skyField as bool

  
  private snowField as bool

  
  private wspdField as bool

  
  private wdirField as bool

  
  private wxField as bool

  
  private wavehField as bool

  
  private iconsField as bool

  
  private rhField as bool

  
  private apptField as bool

  
  private conhazoField as bool

  
  private ptornadoField as bool

  
  private phailField as bool

  
  private ptstmwindsField as bool

  
  private pxtornadoField as bool

  
  private pxhailField as bool

  
  private pxtstmwindsField as bool

  
  private ptotsvrtstmField as bool

  
  private pxtotsvrtstmField as bool

  
  private wgustField as bool

  
  private incw34Field as bool

  
  private incw50Field as bool

  
  private incw64Field as bool

  
  private cumw34Field as bool

  
  private cumw50Field as bool

  
  private cumw64Field as bool

  
  public maxt as bool:
    get:
      return self.maxtField
    set:
      self.maxtField = value

  
  public mint as bool:
    get:
      return self.mintField
    set:
      self.mintField = value

  
  public temp as bool:
    get:
      return self.tempField
    set:
      self.tempField = value

  
  public dew as bool:
    get:
      return self.dewField
    set:
      self.dewField = value

  
  public pop12 as bool:
    get:
      return self.pop12Field
    set:
      self.pop12Field = value

  
  public qpf as bool:
    get:
      return self.qpfField
    set:
      self.qpfField = value

  
  public sky as bool:
    get:
      return self.skyField
    set:
      self.skyField = value

  
  public snow as bool:
    get:
      return self.snowField
    set:
      self.snowField = value

  
  public wspd as bool:
    get:
      return self.wspdField
    set:
      self.wspdField = value

  
  public wdir as bool:
    get:
      return self.wdirField
    set:
      self.wdirField = value

  
  public wx as bool:
    get:
      return self.wxField
    set:
      self.wxField = value

  
  public waveh as bool:
    get:
      return self.wavehField
    set:
      self.wavehField = value

  
  public icons as bool:
    get:
      return self.iconsField
    set:
      self.iconsField = value

  
  public rh as bool:
    get:
      return self.rhField
    set:
      self.rhField = value

  
  public appt as bool:
    get:
      return self.apptField
    set:
      self.apptField = value

  
  public conhazo as bool:
    get:
      return self.conhazoField
    set:
      self.conhazoField = value

  
  public ptornado as bool:
    get:
      return self.ptornadoField
    set:
      self.ptornadoField = value

  
  public phail as bool:
    get:
      return self.phailField
    set:
      self.phailField = value

  
  public ptstmwinds as bool:
    get:
      return self.ptstmwindsField
    set:
      self.ptstmwindsField = value

  
  public pxtornado as bool:
    get:
      return self.pxtornadoField
    set:
      self.pxtornadoField = value

  
  public pxhail as bool:
    get:
      return self.pxhailField
    set:
      self.pxhailField = value

  
  public pxtstmwinds as bool:
    get:
      return self.pxtstmwindsField
    set:
      self.pxtstmwindsField = value

  
  public ptotsvrtstm as bool:
    get:
      return self.ptotsvrtstmField
    set:
      self.ptotsvrtstmField = value

  
  public pxtotsvrtstm as bool:
    get:
      return self.pxtotsvrtstmField
    set:
      self.pxtotsvrtstmField = value

  
  public wgust as bool:
    get:
      return self.wgustField
    set:
      self.wgustField = value

  
  public incw34 as bool:
    get:
      return self.incw34Field
    set:
      self.incw34Field = value

  
  public incw50 as bool:
    get:
      return self.incw50Field
    set:
      self.incw50Field = value

  
  public incw64 as bool:
    get:
      return self.incw64Field
    set:
      self.incw64Field = value

  
  public cumw34 as bool:
    get:
      return self.cumw34Field
    set:
      self.cumw34Field = value

  
  public cumw50 as bool:
    get:
      return self.cumw50Field
    set:
      self.cumw50Field = value

  
  public cumw64 as bool:
    get:
      return self.cumw64Field
    set:
      self.cumw64Field = value


[System.CodeDom.Compiler.GeneratedCodeAttribute('wsdl', '2.0.50727.312')]
public callable NDFDgenCompletedEventHandler(sender as object, e as NDFDgenCompletedEventArgs) as void

[System.CodeDom.Compiler.GeneratedCodeAttribute('wsdl', '2.0.50727.312')]
[System.Diagnostics.DebuggerStepThroughAttribute]
[System.ComponentModel.DesignerCategoryAttribute('code')]
partial public class NDFDgenCompletedEventArgs(System.ComponentModel.AsyncCompletedEventArgs):

  
  private results as (object)

  
  internal def constructor(results as (object), exception as System.Exception, cancelled as bool, userState as object):
    super(exception, cancelled, userState)
    self.results = results

  
  public Result as string:
    get:
      self.RaiseExceptionIfNecessary()
      return cast(string, self.results[0])


[System.CodeDom.Compiler.GeneratedCodeAttribute('wsdl', '2.0.50727.312')]
public callable NDFDgenByDayCompletedEventHandler(sender as object, e as NDFDgenByDayCompletedEventArgs) as void

[System.CodeDom.Compiler.GeneratedCodeAttribute('wsdl', '2.0.50727.312')]
[System.Diagnostics.DebuggerStepThroughAttribute]
[System.ComponentModel.DesignerCategoryAttribute('code')]
partial public class NDFDgenByDayCompletedEventArgs(System.ComponentModel.AsyncCompletedEventArgs):

  
  private results as (object)

  
  internal def constructor(results as (object), exception as System.Exception, cancelled as bool, userState as object):
    super(exception, cancelled, userState)
    self.results = results

  
  public Result as string:
    get:
      self.RaiseExceptionIfNecessary()
      return cast(string, self.results[0])

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
  

