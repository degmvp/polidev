8 - Deprecated Warning
def deprecated(reason=""):

    def decorator(func):

        @wraps(func)
        def wrapper(*args, **kwargs):

            print("Função depreciada")

            return func(*args, **kwargs)

        return wrapper

    return decorator