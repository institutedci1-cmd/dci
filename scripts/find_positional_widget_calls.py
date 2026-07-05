import re
from pathlib import Path

patterns = ['Container', 'Expanded']
base = Path('lib')

for p in base.rglob('*.dart'):
    text = p.read_text(encoding='utf-8')
    for name in patterns:
        for m in re.finditer(rf'\b{name}\s*\(', text):
            idx = m.end()
            # skip whitespace
            while idx < len(text) and text[idx].isspace():
                idx += 1
            # capture next token until colon or paren
            token = ''
            j = idx
            while j < len(text) and (text[j].isalnum() or text[j] in "._"): j += 1
            token = text[idx:j]
            # check if next non-space char after token is ':' meaning named arg
            k = j
            while k < len(text) and text[k].isspace(): k += 1
            nextch = text[k] if k < len(text) else ''
            if nextch != ':':
                # report context
                start = text.rfind('\n', 0, m.start())+1
                line = text.count('\n', 0, m.start())+1
                snippet = text[start:start+120].split('\n')[0]
                print(f"{p}: {name} at line {line} seems to have positional arg starting with '{token}' -> next char '{nextch}'")
