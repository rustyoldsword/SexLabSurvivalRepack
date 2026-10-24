# Owner's rewritten texts (work\SLS_revision_voice\lines\revision_lines_owner.csv, 2026-10-24) for the suitors, the
# kennel job and Mjoll's quest in SL Survival - Revision Tweaks.esp. Text only - the lines stay unvoiced for now, the old
# .fuz were moved out (they spoke the old words). Notifications live in the scripts (_SLS_TIF_KennelWork / StrongWoman).
#   python -I gen_revision_text.py   -> manifest_revision_text.json (housecarl_apply into the plugin)
import csv
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, '..', '..', 'SLS_revision_voice', 'lines', 'revision_lines_owner.csv')
P = 'SL Survival - Revision Tweaks.esp'
QUEST = f'000817:{P}'


def main():
    ops = []
    for r in csv.DictReader(open(SRC, encoding='utf-8')):
        rec, text = r['record'], r['text']
        kind, _, rest = rec.partition(' ')
        if kind == 'INFO':
            ops.append({'formid': f'{rest}:{P}', 'field_path': 'Responses[0].Text', 'value': text})
        elif kind == 'DIAL':
            ops.append({'formid': f'{rest}:{P}', 'field_path': 'Name', 'value': text})
        elif kind == 'QUST':
            if rest == '000817':
                ops.append({'formid': QUEST, 'field_path': 'Name', 'value': text})
            elif 'objective' in rest:
                i = {'10': 0, '20': 1, '30': 2, '40': 3}[rest.split()[-1]]
                ops.append({'formid': QUEST, 'field_path': f'Objectives[{i}].DisplayText', 'value': text})
            elif 'stage' in rest:
                i = {'10': 0, '40': 1, '100': 2}[rest.split()[-1]]
                ops.append({'formid': QUEST, 'field_path': f'Stages[{i}].LogEntries[0].Entry', 'value': text})
    json.dump(ops, open(os.path.join(HERE, 'manifest_revision_text.json'), 'w', encoding='utf-8'), indent=1)
    print(len(ops), 'ops')


if __name__ == '__main__':
    main()
