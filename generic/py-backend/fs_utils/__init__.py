"""
  FS utils:

  * list_dir(directories) - returns list of all the files and dirs
                            within the given directories
  * get_editor_config(file_path) - returns editor preferences for the given file using
                                   editorconfig specs
  * watch_changes(directories) - watch for fs events within the given directories
  * rm(path) - removes file at the given path
  * rename(path, new_path) - renames/moves file at the given path
  * guess_file_path(app_name, file_name) - play "guess content hub's source file's name" game
                                         using app name and file name as input data
"""

__all__ = ["list_dir", "get_editor_config", "watch_changes", "rm", "rename",
           "guess_file_path", "test_exec"]

from .list_dir import list_files, watch_changes
from .rm import rm
from .rename import rename
from .editor_config import get_editor_config
from .content_hub import guess_file_path
from .which import test_exec
