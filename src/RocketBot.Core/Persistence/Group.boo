
namespace PredibotLib

import System
import System.Collections.Generic
import System.Text

public class Group:

	
	private _name as string

	public Name as string:
		get:
			return _name
		set:
			_name = value

	
	private _privTitles as string

	public PrivTitles as string:
		get:
			return _privTitles
		set:
			_privTitles = value

	
	private _createDate as date

	public CreateDate as date:
		get:
			return _createDate
		set:
			_createDate = value

	
	private _parameters as Dictionary[of string, string]

	
	public def constructor(name as string, privTitles as string, createDate as date):
		
		Name = name
		PrivTitles = privTitles
		CreateDate = createDate
		

	
	public static def CompareByDate(item1 as Group, item2 as Group) as int:
		return Comparer[of date].Default.Compare(item1.CreateDate, item2.CreateDate)

	
	public static def CompareByName(item1 as Group, item2 as Group) as int:
		return Comparer[of string].Default.Compare(item1.Name, item2.Name)

	
	public def DoesParameterExist(key as string) as bool:
		
		
		if not _parameters.ContainsKey(key):
			return false
		else:
			return true

	
	public def SetParameter(key as string, value as string):
		
		_parameters[key] = value
		

	
	public def GetParameter(key as string) as string:
		
		param = ''
		try:
			
			param = _parameters[key]
		
		except :
			
			return ''
		
		
		return param
		
	
	

