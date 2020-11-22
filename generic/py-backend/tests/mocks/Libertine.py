from unittest.mock import Mock

class LibertineContainer:
    def __init__(self, container_id, containers_config=None, service=None):
        pass

    def configure_add_archive(self, url, key):
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
