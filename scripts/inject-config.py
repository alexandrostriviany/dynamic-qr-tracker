"""Inject configuration placeholders in index.html.

Replaces __GA4_MEASUREMENT_ID__, __DEFAULT_URL__, and __ROUTES_JSON__
with actual values passed as command-line arguments.

Usage: python3 scripts/inject-config.py <html_file> <ga4_id> <default_url> <routes_json>
"""
import sys

html_file = sys.argv[1]
ga4_id = sys.argv[2]
default_url = sys.argv[3]
routes_json = sys.argv[4]

with open(html_file) as f:
    content = f.read()

content = content.replace("__GA4_MEASUREMENT_ID__", ga4_id)
content = content.replace("__DEFAULT_URL__", default_url)
content = content.replace("__ROUTES_JSON__", routes_json)

with open(html_file, "w") as f:
    f.write(content)
