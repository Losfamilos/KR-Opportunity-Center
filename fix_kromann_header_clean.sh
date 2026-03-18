#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-index.html}"

python - <<'PY' "$TARGET"
from pathlib import Path
import re
import sys

target = Path(sys.argv[1])
s = target.read_text(encoding="utf-8")

# 1) Title
s = s.replace(
    "<title>Bech-Bruun | Ledelsesoverblik (demo)</title>",
    "<title>Kromann Reumert | Ledelsesoverblik (demo)</title>"
)
s = s.replace(
    "<title>Kromann Reumert | Ledelsesoverblik (demo)</title>",
    "<title>Kromann Reumert | Ledelsesoverblik (demo)</title>"
)

# 2) Replace entire left brand block with clean text-based wordmark
s = re.sub(
    r'<!-- Left: Brand -->\s*<div class="flex items-center flex-shrink-0.*?<!-- Right: Everything -->',
    '''<!-- Left: Brand -->
    <div class="flex items-center flex-shrink-0 min-w-0">
      <div class="min-w-0">
        <div class="leading-none">
          <div class="text-[1.6rem] sm:text-[1.9rem] lg:text-[2.15rem] font-light tracking-[0.18em] text-[#123b63] uppercase whitespace-nowrap">
            Kromann
          </div>
          <div class="text-[1.6rem] sm:text-[1.9rem] lg:text-[2.15rem] font-light tracking-[0.18em] text-[#123b63] uppercase whitespace-nowrap -mt-1">
            Reumert
          </div>
        </div>
        <p class="text-[0.6875rem] font-medium text-stone-500 tracking-wider uppercase mt-1 whitespace-nowrap">Ledelsesoverblik (demo)</p>
      </div>
    </div>

    <!-- Right: Everything -->''',
    s,
    count=1,
    flags=re.DOTALL
)

# 3) Make header spacing more robust
s = s.replace(
    'max-w-[1800px] mx-auto px-4 sm:px-6 lg:px-16 py-5 lg:py-7 flex items-center justify-between gap-8',
    'max-w-[1800px] mx-auto px-4 sm:px-6 lg:px-10 xl:px-16 py-4 lg:py-5 flex items-center justify-between gap-4 xl:gap-8'
)

s = s.replace(
    'flex flex-col lg:flex-row lg:items-center lg:justify-end gap-3 lg:gap-3 w-auto',
    'flex flex-col lg:flex-row lg:items-center lg:justify-end gap-3 lg:gap-3 w-auto min-w-0'
)

s = s.replace(
    'flex items-center gap-6 w-full lg:w-auto flex-shrink-0',
    'flex items-center gap-4 xl:gap-6 w-full lg:w-auto flex-shrink-0'
)

# 4) Partner dropdown width
s = s.replace('w-[190px]', 'w-[165px]')
s = s.replace('w-[170px]', 'w-[165px]')
s = s.replace('w-[160px]', 'w-[165px]')

# 5) Clean top-right user block
s = re.sub(
    r'<div class="flex items-center gap-3(?: flex-shrink-0)?">\s*<div class="text-right(?: hidden 2xl:block| hidden xl:block)?">\s*<p class="text-sm font-semibold text-stone-900 whitespace-nowrap">.*?</p>\s*<p class="text-xs text-stone-500 whitespace-nowrap">.*?</p>\s*</div>\s*<div class="w-\d+ h-\d+(?: xl:w-\d+ xl:h-\d+)? rounded-xl bg-gradient-to-br from-slate-800 to-slate-900 flex items-center justify-center text-white(?: text-sm)? font-semibold shadow-lg ring-2 ring-white">\s*.*?\s*</div>\s*</div>',
    '''<div class="flex items-center gap-3 flex-shrink-0">
          <div class="text-right hidden xl:block">
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

# 6) Last safety replacements
s = s.replace(">Camilla Huus<", ">Jeppe Buskov<")
s = s.replace(">Chief Operating Officer<", ">Partner<")
s = s.replace("Bech-Bruun", "Kromann Reumert")

target.write_text(s, encoding="utf-8")
print(f"Updated: {target}")
PY

echo "Done."
