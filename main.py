#!/usr/bin/env python3
import requests


def main() -> None:
    print("hiii :3")

    resp = requests.get("https://icanhazip.com")
    print(f"your IP is {resp.text}")


if __name__ == "__main__":
    main()
