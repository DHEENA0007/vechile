import re

fname = 'lib/screens/owner/owner_center_screen.dart'
with open(fname, 'r') as f:
    content = f.read()

content = re.sub(r'\bTextStyle\(', 'GoogleFonts.outfit(', content)
content = re.sub(r'const\s+GoogleFonts\.outfit', 'GoogleFonts.outfit', content)

if 'package:google_fonts/google_fonts.dart' not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:google_fonts/google_fonts.dart';")

with open(fname, 'w') as f:
    f.write(content)
