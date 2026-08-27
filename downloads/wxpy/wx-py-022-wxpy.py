2 - Retry com Exponential Backoff
Padrão extremamente utilizado em APIs, cloud computing, microservices e automação resiliente.

def retry(max_attempts=3, delay=1.0):

    def decorator(func):

        @wraps(func)
        def wrapper(*args, **kwargs):

            for attempt in range(1, max_attempts + 1):

                try:
                    return func(*args, **kwargs)

                except Exception:

                    wait = delay * (2 ** (attempt - 1))

                    time.sleep(wait)

        return wrapper

    return decorator