9 - Validate Input Types
def validate_types(**type_hints):

    def decorator(func):

        @wraps(func)
        def wrapper(*args, **kwargs):

            for name, expected_type in type_hints.items():

                if name in kwargs and \
                   not isinstance(kwargs[name], expected_type):

                    raise TypeError()

            return func(*args, **kwargs)

        return wrapper

    return decorator