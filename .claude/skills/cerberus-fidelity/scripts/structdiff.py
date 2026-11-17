"""Compare the layout structure of two emails, ignoring content, colors and fonts.

Tags inside Outlook conditional comments count (they are markup for Outlook). Each tag is
reduced to: name + attributes (minus src/alt/href) + inline style properties that are not
colors or fonts. Text-level tags (p, h1, ul, li, ...) are skipped as content.

Usage: python3 -I structdiff.py <upstream.html> <ported.html>
Exit code: 0 identical, 1 differences.
"""
import difflib
import re
import sys

THEMED = {"color", "background", "background-color", "font-family", "border-color", "border"}
SKIP_ATTRS = {"src", "alt", "href"}
CONTENT_TAGS = {"p", "h1", "h2", "ul", "li", "br", "span", "webversion", "unsubscribe", "link", "meta"}


def tokens(path):
    html = open(path, encoding="utf-8").read()
    # Unwrap conditional comments so Outlook-only markup is compared too.
    html = re.sub(r"<!--\[if[^\]]*\]>|<!\[endif\]-->|<!--<!\[endif\]-->|<!--\[if !mso\]><!-->", " ", html)
    html = re.sub(r"<!--.*?-->", " ", html, flags=re.S)
    html = re.sub(r"<head\b.*?</head>", "", html, flags=re.S | re.I)  # head: see cssdiff.py
    out = []
    for m in re.finditer(r"<(/?)([a-zA-Z][a-zA-Z0-9:]*)([^>]*)>", html):
        close, name, rest = m.groups()
        name = name.lower()
        if name in CONTENT_TAGS:
            continue
        if close:
            out.append(f"</{name}>")
            continue
        attrs = {k.lower(): v for k, v in re.findall(r'([\w:-]+)="([^"]*)"', rest)}
        style = attrs.pop("style", "")
        pairs = (p.split(":", 1) for p in style.split(";") if ":" in p)
        props = sorted(f"{k.strip().lower()}:{v.strip()}" for k, v in pairs if k.strip().lower() not in THEMED)
        kept = sorted(f'{k}="{v}"' for k, v in attrs.items() if k not in SKIP_ATTRS)
        out.append(f"<{name} {' '.join(kept)} [{'; '.join(props)}]>")
    return out


if __name__ == "__main__":
    a, b = tokens(sys.argv[1]), tokens(sys.argv[2])
    diff = list(difflib.unified_diff(a, b, "upstream", "ported", lineterm="", n=1))
    print("\n".join(diff) if diff else "IDENTICAL layout structure")
    print(f"\n{len(a)} upstream tags, {len(b)} ported tags")
    sys.exit(1 if diff else 0)
