namespace RocketBot.Core

import System
import System.Linq.Enumerable from System.Core
import Db4objects.Db4o

public class User(IPersistable):
  _id as Guid
  public Id as Guid:
    get:
      return _id
  
  _date as date
  public CreateDate as date:
    get:
      return _date
  
  _nick as string
  public Nick as string:
    get:
      return _nick
  
  private def constructor(nick as string):
    _id = Guid.NewGuid()
    _date = DateTime.Now
    _nick = nick
  
  private static def New(nick as string) as User:
    user = User(nick)
    Database.Store(user)
    return user
  
  public static def UserExistsByNick(nick as string) as bool:
    query = {x as IObjectContainer | x.Query[of User]({y as User | y.Nick == nick}).ToList()}
    return Database.Query[of User](query).Count() > 0
  
  public static def GetByNick(nick as string) as User:
    user as User
    if UserExistsByNick(nick):
      query = {x as IObjectContainer | x.Query[of User]({y as User | y.Nick == nick}).Single()}
      user = Database.Query[of User](query)
    else:
      user = New(nick)
    return user