﻿namespace RocketBot.Core

import System
import System.Collections.Generic

public interface IPlugin:
  Name as string:
    get

  Description as string:
    get

  Version as string:
    get

  Author as string:
    get

  def GetCommands() as List[of CommandWrapper]