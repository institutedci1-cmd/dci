import sys
from pathlib import Path

files = [
    'lib/pages/login/login_widget.dart',
    'lib/pages/daily_report_form/daily_report_form_widget.dart',
    'lib/pages/attendance_tracker/attendance_tracker_widget.dart',
    'lib/pages/homework_assignment/homework_assignment_widget.dart',
]

pairs = {'(': ')', '{': '}', '[': ']'}
openers = set(pairs.keys())
closers = {v: k for k, v in pairs.items()}

ok = True
for f in files:
    p = Path(f)
    if not p.exists():
        print(f'MISSING: {f}')
        ok = False
        continue
    stack = []
    with p.open(encoding='utf-8') as fh:
        for i, line in enumerate(fh, start=1):
            for j, ch in enumerate(line, start=1):
                if ch in openers:
                    stack.append((ch, i, j))
                elif ch in closers:
                    if not stack:
                        print(f'{f}: Unmatched closer {ch} at {i}:{j}')
                        ok = False
                        break
                    last, li, lj = stack.pop()
                    if closers[ch] != last:
                        print(f"{f}: Mismatched {last} opened at {li}:{lj} but closed by {ch} at {i}:{j}")
                        ok = False
                        break
            else:
                continue
            break
    if stack:
        for ch, li, lj in stack:
            print(f'{f}: Unclosed {ch} at {li}:{lj}')
        ok = False

if not ok:
    sys.exit(2)
print('All files bracket-balanced')
