
namespace PredibotLib

import System
import System.Collections.Generic
import System.Text

public class BandName:

	private _name as string

	public Name as string:
		get:
			return _name
		set:
			_name = value

	
	private _owner as User

	public Owner as User:
		get:
			return _owner
		set:
			_owner = value

	
	public attributionUser as User

	
	private _createDate as date

	public CreateDate as date:
		get:
			return _createDate
		set:
			_createDate = value

	
	public def constructor(name as string, owner as User, createDate as date):
		Name = name
		Owner = owner
		CreateDate = createDate

	
	public static def CompareByDate(item1 as BandName, item2 as BandName) as int:
		
		return Comparer[of date].Default.Compare(item1.CreateDate, item2.CreateDate)
		
	
	

