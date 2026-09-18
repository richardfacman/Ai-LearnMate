import os

replacements = {
    '0xFF05070F': '0xFF0B0B14',
    '0xFF0F1422': '0xFF15151F',
    '0xFFF0A93E': '0xFFFFB020',
    '0xFFFFC44D': '0xFFFFB020',
    '0xFFEE9F16': '0xFFFFB020'
}

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            modified = False
            for old, new in replacements.items():
                if old in content:
                    content = content.replace(old, new)
                    modified = True

            if modified:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f'Updated {filepath}')
