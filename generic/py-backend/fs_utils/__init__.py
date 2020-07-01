"""
  FS utils:

  * list_dir(root_directory, children) - returns list of all the files and dirs
                                         withing the given root and childrent directories
"""

__all__ = ["list_dir", "get_editor_config"]

from .list_dir import list_dir
from .editor_config import get_editor_config
