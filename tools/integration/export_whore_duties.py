# Whore licence duty lines (SL Survival - Revision Tweaks.esp) exported for the owner to rewrite and voice elsewhere.
# Voice types: clients = the 29 male voice types the suitors use; guards = the types SLS's own curfew guard lines are
# voiced in (Desktop export sls_paths.csv, topic _SLS_CurfewIntro00 INFOs).
#   python -I export_whore_duties.py <out dir>
import csv
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SLS_PATHS = r'C:\Modding\SLS vanilla voice lines\sls_paths.csv'
LINES = os.path.join(r'C:\Modding\SLS vanilla voice lines', 'sls_lines.csv')
sys.path.insert(0, HERE)
from gen_whore_duties import CLIENT_ANS, CLIENT_OPEN, GUARD_ANS, GUARD_OPEN  # noqa: E402


def prefix(quest, topic):
    q, t = quest.lower(), topic.lower()
    if len(q) + len(t) > 25:
        q, t = q[:10], t[:15]
    return f'{q}_{t}'


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    ids = json.load(open(os.path.join(HERE, 'wl_ids.json'), encoding='utf-8'))
    males = json.load(open(os.path.join(HERE, '..', '..', 'SLS_voice_extra', 'targets.json'), encoding='utf-8'))['voices']
    curfew = {r['info_formid'] for r in csv.DictReader(open(LINES, encoding='utf-8-sig')) if r['topic'] == '_SLS_CurfewIntro00'}
    guards = sorted({r['voice_type'] for r in csv.DictReader(open(SLS_PATHS, encoding='utf-8-sig')) if r['info_formid'] in curfew})
    rows = []

    def fid(eid):
        return int(ids[eid].split(':')[0], 16)

    for side, quest, openers, answers, vts in (('client', '_SLSRT_WL_Client', CLIENT_OPEN, CLIENT_ANS, males),
                                                ('guard', '_SLSRT_WL_Guard', GUARD_OPEN, GUARD_ANS, guards)):
        for n, text in enumerate(openers, 1):
            eid = f'{quest}Greet{n:02d}'
            rows.append([eid, side, 'NPC walks up and says one of these (random)', text,
                         f"{prefix(quest, quest + 'Greet')}_{fid(eid):08x}_1", ' '.join(vts)])
        for n, (prompt, reply) in enumerate(answers):
            rows.append([f'{quest}Ans{n}', side, 'heroine (menu line, not voiced)', prompt, '', ''])
            eid = f'{quest}Ans{n}_01'
            rows.append([eid, side, f'NPC answers to "{prompt}"', reply,
                         f"{prefix(quest, f'{quest}Ans{n}')}_{fid(eid):08x}_1", ' '.join(vts)])
    with open(os.path.join(out, 'whore_licence_lines.csv'), 'w', encoding='utf-8-sig', newline='') as f:
        w = csv.writer(f)
        w.writerow(['id', 'speaker', 'when', 'text (as in game)', 'file_name (one per voice type folder)', 'voice_types'])
        w.writerows(rows)
    print(len(rows), 'rows; guard voice types:', guards)


if __name__ == '__main__':
    main()
