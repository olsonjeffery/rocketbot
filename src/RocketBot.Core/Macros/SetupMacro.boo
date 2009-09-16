namespace RocketBot.Core

import System
import Boo.Lang.Compiler.Ast

macro setup:
  raise "there can be no arguments to a 'setup' block" if setup.Arguments.Count != 0
  st = ExpressionStatement()
  st.Annotate("setup", "setup")
  
  method = Method()
  method.Name = "Setup"
  method.Body = setup.Body.Clone()
  st.Annotate("method", method)
  return st