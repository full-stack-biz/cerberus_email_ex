"""Compare the <head> CSS of two emails rule by rule, in order, with colors and fonts masked.

Usage: python3 -I cssdiff.py <upstream.html> <ported.html>
Exit code: 0 identical, 1 differences.
"""
import difflib
import re
import sys


def css(path):
    html = open(path, encoding="utf-8").read()
    text = " ".join(re.findall(r"<style>(.*?)</style>", html, re.S))
    # Color-only rules this library adds to the dark mode block; not in upstream.
    text = re.sub(r"/\* Theme addition : BEGIN \*/.*?/\* Theme addition : END \*/", "", text, flags=re.S)
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"#[0-9A-Fa-f]{3,6}\b", "#COLOR", text)
    text = re.sub(r"font-family:[^;]+;", "font-family:F;", text)
    return [line.strip() for line in re.sub(r"\s+", " ", text).replace("}", "}\n").splitlines()]


if __name__ == "__main__":
    diff = list(difflib.unified_diff(css(sys.argv[1]), css(sys.argv[2]), "upstream", "ported", lineterm="", n=0))
    print("\n".join(diff) if diff else "IDENTICAL head CSS")
    sys.exit(1 if diff else 0)
