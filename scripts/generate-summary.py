"""Generate GitHub Actions step summary with QR code links.

Reads the already-injected public/index.html to extract route keys,
then builds a markdown table of QR-ready URLs with UTM parameters.

Usage: python3 scripts/generate-summary.py <base_url> <html_file> <summary_file>
"""
import sys
import json
import re

base_url = sys.argv[1]
html_file = sys.argv[2]
summary_file = sys.argv[3]

with open(html_file) as f:
    html = f.read()

# Find the ROUTES object in the injected HTML
# Matches: ROUTES: {"default":"https://...", ...}
match = re.search(r'ROUTES:\s*(\{[^}]+\})', html)
if not match:
    print("WARNING: Could not find ROUTES in index.html")
    sys.exit(0)

routes = json.loads(match.group(1))

lines = []
lines.append("## Deployment Complete\n")
lines.append(f"**Live site:** {base_url}\n")
lines.append("## QR Code Links\n")
lines.append("Copy any link below into your QR code design app.\n")
lines.append("| Route | URL |")
lines.append("|-------|-----|")

for key in routes:
    if key == "default":
        url = f"{base_url}/?utm_source=qr&utm_medium=qr&utm_campaign={key}"
    else:
        url = f"{base_url}/?r={key}&utm_source=qr&utm_medium=qr&utm_campaign={key}"
    lines.append(f"| {key} | `{url}` |")

lines.append("\n---")
lines.append("*Each link includes UTM parameters for GA4 campaign tracking.*")

with open(summary_file, "a") as f:
    f.write("\n".join(lines) + "\n")
