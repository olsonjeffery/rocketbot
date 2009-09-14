namespace RocketBot.Core

import System

public class User:
  
  [property(Nick)]
  _nick as string
  
  public def constructor(nick as string):
    Nick = nick

