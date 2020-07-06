"""
Watching for FS events (file created/deleted/moved).

A most simple implementation I could think of.
Watcher class provides the `watch` method
that starts a new thread to wait for a first FS event.
When FS event happens a given callback is executed and the thread exits.
"""
from threading import Thread
from inotify_simple import INotify, flags

class Watcher: # pylint: disable=too-few-public-methods
    """Watcher class. Provides `watch` method to execute callback when event happens"""
    def __init__(self, callback):
        self._inotify = None
        self._thread = None
        self._watch_descriptors = []
        self._callback = callback

    def watch(self, directories):
        """
        Creates a thread to watch for a single fs event.
        Executes callback once when any monitored event happens.
        Removes existing watchers on initialization,
        so only one watching thread exists at a time.

        Keyword arguments:
        directories -- directories to watch
        callback -- function to execute on event
        """
        if self._inotify:
            for descriptor in self._watch_descriptors:
                self._inotify.rm_watch(descriptor)
            self._watch_descriptors = []
            self._inotify.close()
        self._thread = Thread(target=self._notify_changes, args=(directories,))
        self._thread.start()

    def get_notification_thread(self):
        """Returns notification thread"""
        return self._thread

    def _notify_changes(self, directories):
        """
        Registers notification on FS events.

        Keyword arguments:
        directory -- directory to watch
        callback -- function to execute on event
        """
        self._inotify = INotify()
        watch_flags = flags.CREATE | flags.DELETE | flags.MODIFY | flags.MOVED_FROM | \
                      flags.MOVED_TO | flags.DELETE_SELF
        for directory in directories:
            self._watch_descriptors.append(self._inotify.add_watch(directory, watch_flags))

        # wait for event
        try:
            self._inotify.read()
            self._callback()
        except ValueError:
            # do not care if the watcher has been removed / thread killed
            pass
