
namespace PredibotLib

import System
import System.Collections.Generic
import System.Text

public class ChannelTopic:

	
	public User as User

	public Topic as string

	public PostDate as date

	public Channel as string

	
	public def constructor(user as User, topic as string, postDate as date, channel as string):
		
		User = user
		Topic = topic
		PostDate = postDate
		Channel = channel
		

	
	public static def CompareByDate(item1 as ChannelTopic, item2 as ChannelTopic) as int:
		
		return Comparer[of date].Default.Compare(item1.PostDate, item2.PostDate)
		
	
	

