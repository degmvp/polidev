4 - Logging Automático
def log_execution(level="info"):

    def decorator(func):

        @wraps(func)
        def wrapper(*args, **kwargs):

            logger = logging.getLogger(func.__module__)

            logger.info(f"Executando {func.__name__}")

            result = func(*args, **kwargs)

            logger.info(f"Retorno: {result}")

            return result

        return wrapper

    return decorator