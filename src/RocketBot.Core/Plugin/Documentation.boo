namespace RocketBot.Core

import System
import System.Collections.Generic

public static class Docs:
  _docs as Dictionary[of string, string]
  public def InitDocsIfNeeded():
    _docs = Dictionary[of string, string]() if _docs is null
  
  public def GetTopics() as string*:
    InitDocsIfNeeded()
    return _docs.Keys
  
  public def GetDocsFor(topic as string) as string*:
    InitDocsIfNeeded()
    
    return null if not _docs.ContainsKey(topic)
    print "raw doc: '"+_docs[topic]+"'"
    delims = ("\\r\\n", "\r\n", "\n")
    temp = _docs[topic].Trim().Split(delims, StringSplitOptions.RemoveEmptyEntries)
    retList = List of string()
    if temp.Length == 1:
      retList.Add(temp[0])
    else:
      for line in temp:
        retList.Add(line)
    return retList
  
  public def AddDocsFor(topic as string, rawDocs as string):
    InitDocsIfNeeded()
    raise "duplicate documentation for '"+topic+"'!" if _docs.ContainsKey(topic)
    _docs[topic] = rawDocs