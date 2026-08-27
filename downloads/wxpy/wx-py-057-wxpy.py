bbpy04.py
import subprocess

commit_message = "BLACK BELT AUTO DEPLOY"

commands = [
    ["git", "add", "."],
    ["git", "commit", "-m", commit_message],
    ["git", "push"]
]

for cmd in commands:

    print(f"\nRUNNING: {' '.join(cmd)}")

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True
    )

    print(result.stdout)

    if result.stderr:
        print(result.stderr)