import os
import re

target_dir = '/run/media/dheena/Leave you files/vechile/frontend/lib'

patterns_to_remove = [
    r'\.animate\(onPlay:\s*\(c\)\s*=>\s*c\.repeat\(reverse:\s*true\)\)\.scaleXY\(end:\s*[\d\.]+,\s*duration:\s*\d+\.seconds\)',
    r'\.animate\(onPlay:\s*\(c\)\s*=>\s*c\.repeat\(reverse:\s*true\)\)\.scaleXY\(begin:\s*[\d\.]+,\s*end:\s*[\d\.]+,\s*duration:\s*\d+\.seconds,\s*curve:\s*Curves\.[a-zA-Z]+\)',
    r'\.animate\(onPlay:\s*\(controller\)\s*=>\s*controller\.repeat\(reverse:\s*true\)\)\s*\.scaleXY\(begin:\s*[\d\.]+,\s*end:\s*[\d\.]+,\s*duration:\s*\d+\.seconds,\s*curve:\s*Curves\.[a-zA-Z]+\)',
    r'\.animate\(onPlay:\s*\(c\)\s*=>\s*c\.repeat\(reverse:\s*true\)\)\.fadeIn\(duration:\s*\d+\.ms\)'
]

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    for pattern in patterns_to_remove:
        # We replace the infinite scaling animations with a simple fade in so we don't crash the buffer
        content = re.sub(pattern, r'.animate().fadeIn(duration: 800.ms)', content)

    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed animations in {filepath}")

for root, _, files in os.walk(target_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Animation cleanup complete.")
