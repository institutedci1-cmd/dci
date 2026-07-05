from pathlib import Path
p = Path(r'c:/Users/siddi/AppData/Roaming/Code/copilot-terminal-output/copilot-terminal-output-08f1a294-bf11-4cf4-9192-6e1553d30d0b.txt')
if not p.exists():
    print('analyze output not found')
else:
    for i,line in enumerate(p.read_text(encoding='utf-8').splitlines(), start=1):
        if 'Too many positional arguments' in line or 'Expected to find' in line or 'Expected to find ")"' in line or 'Expected to find' in line:
            print(f'{i}: {line}')
