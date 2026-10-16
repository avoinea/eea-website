import pathlib, re, sys

p = pathlib.Path('cypress/support/e2e.js')
if not p.is_file():
    print('NO_FILE')
    sys.exit(0)
t = p.read_text()
if "cy.visit('/cypress/my-page/edit')" in t:
    print('ALREADY_OR_DIFFERENT')
    sys.exit(0)
pat = re.compile(
    r"([ \t]*)cy\.visit\('/cypress/my-page'\);[\s\S]{0,260}?cy\.navigate\('/cypress/my-page/edit'\);"
)
m = pat.search(t)
if not m:
    print('ALREADY_OR_DIFFERENT')
    sys.exit(0)
indent = m.group(1)
new = (
    indent + "// Load the edit route directly instead of pushing it through the SPA\n"
    + indent + "// history: an appHistory push can race with the client hydration, which\n"
    + indent + "// then settles back on the server-rendered view URL and the edit UI\n"
    + indent + "// (including the title editor) never mounts.\n"
    + indent + "cy.visit('/cypress/my-page/edit');"
)
p.write_text(t[:m.start()] + new + t[m.end():])
print('PATCHED')
