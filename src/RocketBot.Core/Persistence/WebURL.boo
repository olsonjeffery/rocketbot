
namespace PredibotLib

import System
import System.Collections.Generic
import System.Text

public class WebURL:

	
	public User as User

	public URL as string

	public PostDate as date

	public Description as string

	
	public def constructor(user as User, url as string, postDate as date, description as string):
		
		User = user
		URL = url
		PostDate = postDate
		Description = description
		

	
	public static def CompareByDate(item1 as WebURL, item2 as WebURL) as int:
		
		return Comparer[of date].Default.Compare(item1.PostDate, item2.PostDate)
		
	
	

