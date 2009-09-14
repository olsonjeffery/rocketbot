
namespace PredibotLib

import System
import System.Collections.Generic
import System.Text

public class GroupMembership:

	
	private _group as Group

	public Group as Group:
		get:
			return _group
		set:
			_group = value

	
	private _user as User

	public User as User:
		get:
			return _user
		set:
			_user = value

	
	private _privLevel as int

	public PrivLevel as int:
		get:
			return _privLevel
		set:
			_privLevel = value

	
	private _membershipDate as date

	public MembershipDate as date:
		get:
			return _membershipDate
		set:
			_membershipDate = value

	
	private _lastPrivChangeDate as date

	public LastPrivChangeDate as date:
		get:
			return _lastPrivChangeDate
		set:
			_lastPrivChangeDate = value

	
	public def constructor(group as Group, user as User, privLevel as int, membershipDate as date):
		
		Group = group
		User = user
		PrivLevel = privLevel
		MembershipDate = membershipDate
		LastPrivChangeDate = membershipDate
		
	
	
	

