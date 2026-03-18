#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-index.html}"

if [ ! -f "$TARGET" ]; then
  echo "Fandt ikke filen: $TARGET"
  exit 1
fi

python - <<'PY' "$TARGET"
from pathlib import Path
import re
import sys

target = Path(sys.argv[1])
s = target.read_text(encoding="utf-8")

logo_data_uri = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAgUAAABhCAIAAADJBEU/AAAgAElEQVR4Ae19z2sUyft//wlKbmMgDDMwQJbECBZDaDCCN0KI4Q2W4IB4QKxEcMTBMXh2Dg6IuI2H4OjFuTF4cYj8AQ6Ojqf3dO9V1dXdXV19fT09PT09PR0fP2eqn7r3n4v+tlXXb11XfXv1VXXq6uqqql6q2mVt7W1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW1tbW3t/wJzM8rjvR+6YwAAAABJRU5ErkJggg=="

# 1) Titel
s = s.replace(
    "<title>Bech-Bruun | Ledelsesoverblik (demo)</title>",
    "<title>Kromann Reumert | Ledelsesoverblik (demo)</title>"
)

# 2) Brand i header
s = re.sub(
    r'<div class="flex items-center flex-shrink-0">\s*<div>\s*<h1 class="serif text-\[1\.75rem\] sm:text-\[2rem\] text-stone-900 tracking-tight whitespace-nowrap">Bech-Bruun</h1>\s*<p class="text-\[0\.6875rem\] font-medium text-stone-500 tracking-wider uppercase mt-0\.5">Ledelsesoverblik \(demo\)</p>\s*</div>\s*</div>',
    f'''<div class="flex items-center flex-shrink-0">
      <div class="flex items-center gap-4">
        <img
          src="{logo_data_uri}"
          alt="Kromann Reumert"
          class="h-12 sm:h-14 lg:h-16 w-auto object-contain"
        />
        <div>
          <p class="text-[0.6875rem] font-medium text-stone-500 tracking-wider uppercase mt-0.5">Ledelsesoverblik (demo)</p>
        </div>
      </div>
    </div>''',
    s,
    count=1,
    flags=re.DOTALL
)

# 3) Partner select
s = re.sub(
    r'<select id="partnerSelect" class="text-xs font-semibold text-stone-900 bg-transparent outline-none w-\[160px\]">\s*<option value="camilla" selected>Camilla Huus</option>\s*<option value="morten">Morten L\.</option>\s*<option value="sara">Sara K\.</option>\s*</select>',
    '''<select id="partnerSelect" class="text-xs font-semibold text-stone-900 bg-transparent outline-none w-[190px]">
              <option value="jeppe" selected>Jeppe Buskov</option>
              <option value="christina">Christina B. Geertsen</option>
              <option value="soren">Søren Skibsted</option>
            </select>''',
    s,
    count=1,
    flags=re.DOTALL
)

# 4) Brugerfelt top højre
s = re.sub(
    r'<div class="flex items-center gap-3">\s*<div class="text-right">\s*<p class="text-sm font-semibold text-stone-900 whitespace-nowrap">.*?</p>\s*<p class="text-xs text-stone-500 whitespace-nowrap">.*?</p>\s*</div>\s*<div class="w-12 h-12 rounded-xl bg-gradient-to-br from-[^"]+ to-[^"]+ flex items-center justify-center text-white font-semibold shadow-lg ring-2 ring-white">\s*.*?\s*</div>\s*</div>',
    '''<div class="flex items-center gap-3">
            <div class="text-right">
              <p class="text-sm font-semibold text-stone-900 whitespace-nowrap">Jeppe Buskov</p>
              <p class="text-xs text-stone-500 whitespace-nowrap">Partner</p>
            </div>
            <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-slate-800 to-slate-900 flex items-center justify-center text-white font-semibold shadow-lg ring-2 ring-white">
              JB
            </div>
          </div>''',
    s,
    count=1,
    flags=re.DOTALL
)

# 5) Partner JS
s = re.sub(
    r'const partners = \{.*?\};',
    '''const partners = {
      jeppe: {
        upside: "+2.4M",
        timeSaved: "11.3h sparet",
        rag: { status: "GREEN", confidence: 94, freshness: "0–2 dage", coverage: "8/10 datapunkter" }
      },
      christina: {
        upside: "+4.1M",
        timeSaved: "8.6h sparet",
        rag: { status: "AMBER", confidence: 88, freshness: "2–7 dage", coverage: "7/10 datapunkter" }
      },
      soren: {
        upside: "+1.7M",
        timeSaved: "6.1h sparet",
        rag: { status: "GREEN", confidence: 92, freshness: "0–2 dage", coverage: "9/10 datapunkter" }
      }
    };''',
    s,
    count=1,
    flags=re.DOTALL
)

# 6) Fallback partner
s = s.replace(
    'partner_view: partnerSelect ? partnerSelect.value : "camilla",',
    'partner_view: partnerSelect ? partnerSelect.value : "jeppe",'
)

# 7) Farver
s = s.replace("background: #115e59;", "background: #123b63;")
s = s.replace("background: #0f4c47;", "background: #0f3151;")
s = s.replace("box-shadow: 0 4px 14px rgba(17, 94, 89, 0.25);", "box-shadow: 0 4px 14px rgba(18, 59, 99, 0.25);")

target.write_text(s, encoding="utf-8")
print(f"Patched: {target}")
PY

echo "Færdig."
