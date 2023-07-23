#!/usr/bin/env python3

import re
import sys

PATTERN = re.compile(r'DOC> (.+?) +:: (.+?)(?: :: (\S+))?$')

def main():
    entries = [
        (name, desc, cat)
        for name, desc, cat in help_entries(sys.stdin)
    ]
    categories = {cat for _, _, cat in entries if cat}
    
    print_entries((name, desc) for name, desc, cat in entries if not cat)
    
    for cat in sorted(categories):
        print(f'\n# {cat}\n')
        print_entries((name, desc) for name, desc, c in entries if c == cat)


def help_entries(inp):  # (name, desc, category)
    for line in inp:
        match = PATTERN.search(line)
        if not match:
            continue
        n, d, c = match.groups()
        yield n.strip(), d.strip(), (c or '').strip()


def print_entries(entries):
    entries = sorted(entries)
    if not entries:
        return
    w = max(len(name) for name, _ in entries)
    for name, desc in entries:
        print(f'{name:{w}} - {desc}')

main()

