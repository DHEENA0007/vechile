import os
import re

target_dir = '/run/media/dheena/Leave you files/vechile/frontend/lib'

replacements = {
    r'const\s+AppTheme\.primary': 'AppTheme.primary',
    r'const\s+AppTheme\.primaryDark': 'AppTheme.primaryDark',
    r'const\s+AppTheme\.bgDark': 'AppTheme.bgDark',
}

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    for pattern, repl in replacements.items():
        content = re.sub(pattern, repl, content)
    
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed {filepath}")

for root, _, files in os.walk(target_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Done fixing consts.")
