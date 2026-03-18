#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-index.html}"

python - <<'PY' "$TARGET"
from pathlib import Path
import re
import sys

target = Path(sys.argv[1])
s = target.read_text(encoding="utf-8")

logo_data_uri = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAgUAAABhCAIAAADJBEU/AAAgAElEQVR4Ae19z2sUyft//wlKbmMgDDMwQJbECBZDaDCCN0KI4Q2W4IB4QKxEcMTBMXh2Dg6IuI2H4OjFuTF4cYj8AQ6Ojqf3dO9V1dXdXV19fT09PT09PR0fP2eqn7r3n4v+tlXXb11XfXv1VXXq6uqqql6q2mVt7W1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW3t/wJzM8rjvR+6YwAAAABJRU5ErkJggg=="

# 1) Sørg for korrekt title
s = s.replace(
    "<title>Bech-Bruun | Ledelsesoverblik (demo)</title>",
    "<title>Kromann Reumert | Ledelsesoverblik (demo)</title>"
)

# 2) Erstat hele venstre brand-blok robust
s = re.sub(
    r'<div class="flex items-center flex-shrink-0.*?</div>\s*</div>\s*<!-- Right: Everything -->',
    f'''<div class="flex items-center flex-shrink-0 min-w-0">
      <div class="flex items-center gap-4 min-w-0">
        <img
          src="{logo_data_uri}"
          alt="Kromann Reumert"
          class="h-10 sm:h-12 lg:h-14 w-auto object-contain flex-shrink-0"
        />
        <div class="min-w-0">
          <p class="text-[0.6875rem] font-medium text-stone-500 tracking-wider uppercase mt-0.5 whitespace-nowrap">Ledelsesoverblik (demo)</p>
        </div>
      </div>
    </div>

    <!-- Right: Everything -->''',
    s,
    count=1,
    flags=re.DOTALL
)

# 3) Gør headeren mere robust
s = s.replace(
    'max-w-[1800px] mx-auto px-4 sm:px-6 lg:px-16 py-5 lg:py-7 flex items-center justify-between gap-8',
    'max-w-[1800px] mx-auto px-4 sm:px-6 lg:px-12 xl:px-16 py-4 lg:py-5 flex items-center justify-between gap-4 xl:gap-8'
)

s = s.replace(
    'flex flex-col lg:flex-row lg:items-center lg:justify-end gap-3 lg:gap-3 w-auto',
    'flex flex-col lg:flex-row lg:items-center lg:justify-end gap-3 lg:gap-3 w-auto min-w-0'
)

s = s.replace(
    'flex items-center gap-6 w-full lg:w-auto flex-shrink-0',
    'flex items-center gap-4 xl:gap-6 w-full lg:w-auto flex-shrink-0'
)

# 4) Lidt smallere partner-dropdown
s = s.replace('w-[190px]', 'w-[165px]')
s = s.replace('w-[170px]', 'w-[165px]')
s = s.replace('w-[160px]', 'w-[165px]')

# 5) Ret brugerfelt helt ude til højre
s = re.sub(
    r'<div class="flex items-center gap-3(?: flex-shrink-0)?">\s*<div class="text-right(?: hidden xl:block)?">\s*<p class="text-sm font-semibold text-stone-900 whitespace-nowrap">Jeppe Buskov</p>\s*<p class="text-xs text-stone-500 whitespace-nowrap">Partner</p>\s*</div>\s*<div class="w-1[12] h-1[12](?: xl:w-12 xl:h-12)? rounded-xl bg-gradient-to-br from-slate-800 to-slate-900 flex items-center justify-center text-white font-semibold shadow-lg ring-2 ring-white">\s*JB\s*</div>\s*</div>',
    '''<div class="flex items-center gap-3 flex-shrink-0">
          <div class="text-right hidden 2xl:block">
            <p class="text-sm font-semibold text-stone-900 whitespace-nowrap">Jeppe Buskov</p>
            <p class="text-xs text-stone-500 whitespace-nowrap">Partner</p>
          </div>
          <div class="w-10 h-10 xl:w-11 xl:h-11 rounded-xl bg-gradient-to-br from-slate-800 to-slate-900 flex items-center justify-center text-white text-sm font-semibold shadow-lg ring-2 ring-white">
            JB
          </div>
        </div>''',
    s,
    count=1,
    flags=re.DOTALL
)

# 6) Hvis teksten stadig står forkert et sted
s = s.replace(">Chief Operating Officer<", ">Partner<")
s = s.replace(">Camilla Huus<", ">Jeppe Buskov<")

target.write_text(s, encoding="utf-8")
print(f"Updated: {target}")
PY

echo "Done."
