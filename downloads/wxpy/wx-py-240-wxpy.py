# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-240
# Performance Profiler
# Categoria: wxpy12
# ==========================================================

import cProfile
import io
import pstats
from functools import wraps

def profile(sort_by="cumulative", lines=10):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            profiler = cProfile.Profile()
            profiler.enable()
            try:
                return func(*args, **kwargs)
            finally:
                profiler.disable()
                stream = io.StringIO()
                stats = pstats.Stats(profiler, stream=stream)
                stats.sort_stats(sort_by)
                stats.print_stats(lines)
                print(stream.getvalue())
        return wrapper
    return decorator
