"""
  Helpers:

  * exec_fn(func) - executes given function,
                    returns result suitable for usage in callback functions
  * exec_cmd(func) - executes given program,
                     yields stdout
"""

__all__ = ["exec_fn", "exec_cmd"]

from .exec_fn import exec_fn
from .exec_cmd import exec_cmd
