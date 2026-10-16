#!/usr/bin/env bash
# Replicate the SonarQube coverage fix (volto-accordion-block 9386b4d) into an
# EEA Volto 19 add-on repository.
#
# Usage: apply-coverage-fix.sh <addon-dir> [push]
#   push: "push" -> also commit and push to origin/volto19
set -euo pipefail

ROOT="/Users/alin/sandbox/eea-website-volto19"
TPL="$ROOT/cookieplone-templates/templates/frontend_addon/{{ cookiecutter.__folder_name }}/.coverage.babel.config.js"
dir="$1"
push="${2:-no}"

cd "$dir"
name="$(basename "$dir")"
branch="$(git branch --show-current 2>/dev/null || true)"

[ "$branch" = "volto19" ] || { echo "SKIP $name (branch=$branch)"; exit 0; }
[ -f "packages/$name/vitest.config.mjs" ] || { echo "SKIP $name (no v19 structure)"; exit 0; }
if [ -f .coverage.babel.config.js ] && [ -z "$(git status --porcelain)" ]; then echo "SKIP $name (already patched)"; exit 0; fi
if [ -n "$(git status --porcelain)" ] && [ ! -f .coverage.babel.config.js ]; then echo "SKIP $name (dirty worktree)"; exit 0; fi

cp "$TPL" .coverage.babel.config.js
echo "PATCH $name"

python3 - "$name" <<'PY'
import pathlib, re, sys

name = sys.argv[1]

def edit(path, fn):
    p = pathlib.Path(path)
    text = p.read_text()
    new = fn(text)
    if new != text:
        p.write_text(new)
        return True
    return False

# 1. Makefile: instrument the CI build (start-ci) with the coverage babel config
new_recipe = (
    "\t# Instrument the build (babel-plugin-istanbul) so Cypress can collect\n"
    "\t# end-to-end coverage; the original babel config is restored on exit.\n"
    "\tcp core/packages/volto/babel.config.js core/packages/volto/babel.config.js.orig\n"
    "\ttrap 'mv -f core/packages/volto/babel.config.js.orig core/packages/volto/babel.config.js' EXIT\n"
    "\tcp .coverage.babel.config.js core/packages/volto/babel.config.js\n"
    "\tpnpm build\n"
    "\tpnpm start:prod\n"
)

def patch_makefile(text):
    pat = r"(start-ci:[^\n]*\n)(\tpnpm build && pnpm start:prod\n)"
    new, n = re.subn(pat, lambda m: m.group(1) + new_recipe, text, count=1)
    if not n:
        print("WARN Makefile: start-ci pattern not found")
    return new

edit('Makefile', patch_makefile)

# 2. root package.json: babel-plugin-istanbul devDependency
def patch_root_pkg(text):
    if '"babel-plugin-istanbul"' in text:
        return text
    new, n = re.subn(
        r'("devDependencies":\s*\{\n)',
        r'\1    "babel-plugin-istanbul": "^6.1.1",\n',
        text,
        count=1,
    )
    if not n:
        print("WARN root package.json: devDependencies not found")
    return new

edit('package.json', patch_root_pkg)

# 3. add-on package.json: istanbul coverage provider instead of v8
pkg = f"packages/{name}/package.json"

def patch_addon_pkg(text):
    if '"@vitest/coverage-v8"' in text:
        return text.replace('"@vitest/coverage-v8"', '"@vitest/coverage-istanbul"')
    if '"@vitest/coverage-istanbul"' in text:
        return text
    m = re.search(r'"vitest":\s*"([^"]+)"', text)
    version = m.group(1) if m else "3.2.7"
    version = version.lstrip("^~")
    new, n = re.subn(
        r'("devDependencies":\s*\{\n)',
        r'\1    "@vitest/coverage-istanbul": "%s",\n' % version,
        text,
        count=1,
    )
    if not n:
        print("WARN add-on package.json: devDependencies not found")
    return new

edit(pkg, patch_addon_pkg)

# 4. vitest config: Istanbul coverage provider (same line model as Cypress)
vitest = f"packages/{name}/vitest.config.mjs"

def patch_vitest(text):
    if "provider: 'istanbul'" in text:
        return text
    if "provider: 'v8'" in text:
        return text.replace("provider: 'v8'", "provider: 'istanbul'")
    if "...voltoVitestConfig," in text:
        return text.replace(
            "  ...voltoVitestConfig,\n",
            "  ...voltoVitestConfig,\n"
            "  coverage: {\n"
            "    ...voltoVitestConfig.coverage,\n"
            "    provider: 'istanbul',\n"
            "  },\n",
        )
    print("WARN vitest.config.mjs: no known coverage pattern, check manually")
    return text

edit(vitest, patch_vitest)
PY

# 5. Commit + push. The lockfiles are intentionally left untouched: these
# clones have no `core/` checkout, so pnpm cannot resolve the workspace here;
# the CI Docker build runs `pnpm install` (not frozen) and updates the lock.
if [ "$push" = "push" ]; then
    git add .coverage.babel.config.js Makefile package.json "packages/$name/package.json" "packages/$name/vitest.config.mjs"
    if git diff --cached --quiet; then echo "NOTHING TO COMMIT $name"; exit 0; fi
    CI=true git commit -m "fix: sonarqube coverage on Volto 19" -m "Restore the Cypress end-to-end coverage instrumentation: babel-plugin-istanbul plus a coverage babel config that instruments only the add-on sources. Unit tests now use the Istanbul coverage provider so the unit and e2e lcov reports share the same line model and can be merged by SonarQube." >/tmp/replicate-commit.log 2>&1
    git push origin volto19 >/tmp/replicate-push.log 2>&1 && echo "PUSHED $name" || { echo "PUSH FAILED $name"; tail -2 /tmp/replicate-push.log; }
fi
