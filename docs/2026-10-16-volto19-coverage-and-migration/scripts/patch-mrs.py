import pathlib, re, sys
p = pathlib.Path('mrs.developer.json')
if not p.is_file():
    print('NO_FILE')
    sys.exit(0)
t = p.read_text()
new, n = re.subn(r'"tag": "19\.3\.0"', '"tag": "19.5.0"', t, count=1)
if n:
    p.write_text(new)
    print('PATCHED')
else:
    print('ALREADY_OR_DIFFERENT')
