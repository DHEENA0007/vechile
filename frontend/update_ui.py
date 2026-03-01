import os
import re

target_dir = '/run/media/dheena/Leave you files/vechile/frontend/lib/screens'

replacements = {
    r'Colors\.white70': 'AppTheme.textSecondary',
    r'Colors\.white\.withOpacity\(0\.5\)': 'AppTheme.textMuted',
    r'Colors\.white\.withValues\(alpha:\s*0\.7\)': 'AppTheme.textSecondary',
    r'Colors\.white\.withValues\(alpha:\s*0\.5\)': 'AppTheme.textMuted',
    r'Colors\.white\.withValues\(alpha:\s*0\.1[0-9]*\)': 'AppTheme.textMuted.withValues(alpha: 0.15)',
    r'Colors\.white24': 'AppTheme.textMuted.withValues(alpha: 0.2)',
    r'Colors\.white': 'AppTheme.textPrimary',
    r'Color\(0xFF0F061E\)': 'AppTheme.bgDark',
    r'Color\(0xFF00B4D8\)': 'AppTheme.primary',
    r'Color\(0xFF0077B6\)': 'AppTheme.primaryDark',
    r'const\s*Color\(0xFF0F172A\)': 'AppTheme.bgDark',
}

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    for pattern, repl in replacements.items():
        content = re.sub(pattern, repl, content)

    # Some specific fixes for Icons where we replaced Colors.white with AppTheme.textPrimary but they shouldn't always be dark
    # Let's keep it simple: textPrimary (which is slate 900) works everywhere except on primary background buttons.
    # On primary background buttons, the text style is already governed by FilledButton style (which uses Colors.white internally in ThemeData).
    # But if there are explicit Text(color: Colors.white) inside FilledButton, they will become textPrimary.
    
    # We will refine 'Colors.white' to only replace when it's text styling or container coloring.
    
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk(target_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

# Also update common widgets
process_file('/run/media/dheena/Leave you files/vechile/frontend/lib/widgets/common_widgets.dart')
print("Done.")
