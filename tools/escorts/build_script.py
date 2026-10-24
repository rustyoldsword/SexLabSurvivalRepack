# Writes the voice-recording script for the escort dialogue from lines.py.
# Run: python -I build_script.py  ->  ESCORT_VOICE_SCRIPT.csv / .md next to this file.
import csv
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from lines import CATEGORIES, CHARACTERS, LINES, PROMPTS  # noqa: E402


def custom_lines():
    # The owner's own lines from custom_lines.csv, appended after the built-in ones of the same character
    extra = {code: [] for code in CHARACTERS}
    path = os.path.join(HERE, 'custom_lines.csv')
    if not os.path.exists(path):
        return extra
    with open(path, encoding='utf-8-sig', newline='') as f:
        for n, row in enumerate(csv.reader(f), 1):
            if n == 1 or not row or not row[0].strip() or row[0].lstrip().startswith('#'):
                continue
            code, cat, text = (row + ['', '', ''])[:3]
            code, cat, text = code.strip().upper(), cat.strip().upper(), text.strip()
            if code not in CHARACTERS or cat not in CATEGORIES or cat == 'TALK' or not text:
                sys.exit(f'custom_lines.csv line {n}: bad character/category or empty line: {row}')
            extra[code].append((cat, text))
    return extra


def rows():
    extra = custom_lines()
    for code, (name, voice, _) in CHARACTERS.items():
        counters = {}
        for cat, text in LINES[code] + extra[code]:
            counters[cat] = counters.get(cat, 0) + 1
            n = counters[cat]
            note = CATEGORIES[cat]
            if cat == 'TALK':
                note = f'Answer to: "{PROMPTS[n - 1]}"'
            yield f'HE_{code}_{cat}_{n:02d}', name, voice, cat, note, text


def main():
    data = list(rows())
    with open(os.path.join(HERE, 'ESCORT_VOICE_SCRIPT.csv'), 'w', encoding='utf-8-sig', newline='') as f:
        w = csv.writer(f)
        w.writerow(['File name (ID)', 'Character', 'Game voice type', 'Category', 'When it plays', 'Line'])
        w.writerows(data)

    md = ['# Hopeless Escorts - voice recording script', '',
          f'{len(data)} lines, 6 characters. Record each line as a separate file named exactly by its ID',
          '(`HE_MIL_HELLO_01.wav`). WAV, mono, 16-bit, 44.1 kHz, about 0.3 s of silence at the start and end,',
          'no music or effects. The player\'s own lines are shown for context only and are not recorded.', '']
    for code, (name, voice, direction) in CHARACTERS.items():
        md += [f'## {name} (`{code}`, game voice {voice})', '', f'_{direction}_', '',
               '| File | When it plays | Line |', '|---|---|---|']
        for rid, cname, _, cat, note, text in data:
            if cname == name:
                md.append(f'| `{rid}` | {note} | {text} |')
        md.append('')
    md += ['## Player lines (not recorded)', ''] + [f'- {p}' for p in PROMPTS]
    with open(os.path.join(HERE, 'ESCORT_VOICE_SCRIPT.md'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(md) + '\n')
    print(len(data), 'lines')


if __name__ == '__main__':
    main()
