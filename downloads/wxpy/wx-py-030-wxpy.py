10 - Performance Profiler
def profile(sort_by="cumulative", lines=10):

    def decorator(func):

        @wraps(func)
        def wrapper(*args, **kwargs):

            pr = cProfile.Profile()

            pr.enable()

            result = func(*args, **kwargs)

            pr.disable()

            return result

        return wrapper

    return decorator