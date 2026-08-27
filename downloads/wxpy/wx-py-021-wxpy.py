1 - Timer Profissional
Decorator para medir tempo de execução com precisão usando time.perf_counter().

def timer(name: str = None):

    def decorator(func):

        @wraps(func)
        def wrapper(*args, **kwargs):

            start = time.perf_counter()

            result = func(*args, **kwargs)

            end = time.perf_counter()

            print(f"{end - start:.6f} segundos")

            return result

        return wrapper

    return decorator