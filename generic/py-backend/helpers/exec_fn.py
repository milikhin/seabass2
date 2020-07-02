"""Helpers for QML integration"""
def exec_fn(func):
    """Executes given function, returns {error,result} dict"""
    try:
        return {'result': func()}
    except Exception as error: # pylint: disable=broad-except
        return {'error': str(error)}
