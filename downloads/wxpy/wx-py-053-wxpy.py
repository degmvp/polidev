bbjack05.py

import subprocess

commands = {

    "1":"dir",
    "2":"git status",
    "3":"python --version"
}

while True:

    print("\n=== AUTOMATION CONTROL CENTER ===\n")

    print("1 - Directory listing")
    print("2 - Git status")
    print("3 - Python version")
    print("0 - Exit")

    option = input("\nOption: ")

    if option == "0":
        break

    if option not in commands:
        print("Invalid option.")
        continue

    command = commands[option]

    print(f"\nRUNNING: {command}\n")

    result = subprocess.run(
        command,
        shell=True,
        capture_output=True,
        text=True
    )

    print(result.stdout)

    if result.stderr:
        print(result.stderr)