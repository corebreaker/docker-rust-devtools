#! /usr/bin/env python3
from toml import load
from sys import exit, stderr

try:
    cargo = load(open('Cargo.toml'))

    print(cargo['package']['name'].replace('-', '_'))
except FileNotFoundError:
    print('This is not a crate', file=stderr)
    exit(10)
