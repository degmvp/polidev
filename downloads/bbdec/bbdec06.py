6 - Async Timer
async def wrapper(*args, **kwargs):

    start = time.perf_counter()

    result = await func(*args, **kwargs)

    end = time.perf_counter()

    print(f"[Async] {end - start:.6f}s")

    return result