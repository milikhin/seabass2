from unittest.mock import Mock

class LibertineContainer:
    def __init__(self, container_id, print_renderer=print):
        self._container_id = container_id
        self._print_renderer = print_renderer
        self._libertine_config = ContainersConfig()
        self._container = None

    def destroy_libertine_container(self, force):
        pass

    def update_libertine_container(self):
        pass

    def install_package(self, package, update_cache, no_dialog):
        return True

class ContainersConfig:
    def container_exists(self, container_id):
        return False

    def refresh_database(self):
        pass
