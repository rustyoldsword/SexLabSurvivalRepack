# Idle chatter cooldown for the escorts (owner, 2026-10-21: "the same line every 10-15 s"). The game asks for idle
# chatter every few seconds and no idle line had a reset time, so a follower talked nonstop. Every idle line
# (_SLSHE_Idle, INFOs 0x803-0x8E5) gets the condition GameDaysPassed >= _SLSHE_IdleNext and the fragment
# _SLSHE_TIF_IdleNext, which pushes _SLSHE_IdleNext by _SLSHE_IdleGap game days when a line is spoken.
# Run: python -I gen_idle_cooldown.py <IdleNext FormID> <IdleGap FormID>  ->  manifest_idle_cooldown.json (apply ops)
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GAME_DAYS_PASSED = '000039:Skyrim.esm'


def main():
    idle_next, idle_gap = sys.argv[1], sys.argv[2]
    ids = []
    with open(os.path.join(HERE, 'infos_formids.jsonl'), encoding='utf-8') as f:
        for n, line in enumerate(f):
            if n:
                fid = json.loads(line)['formid']
                if 0x802 < int(fid.split(':')[0], 16) < 0x8E6:
                    ids.append(fid)
    ops = []
    for fid in ids:
        ops.append({'formid': fid, 'field_path': 'Conditions', 'op': 'Add', 'compose': {
            'type': 'ConditionGlobal', 'fields': {'CompareOperator': 'GreaterThanOrEqualTo', 'ComparisonValue': idle_next},
            'sets': [{'path': 'Data', 'compose': {'type': 'GetGlobalValueConditionData', 'fields': {
                'Global': GAME_DAYS_PASSED, 'RunOnType': 'Subject'}}}]}})
        ops.append({'formid': fid, 'field_path': 'VirtualMachineAdapter', 'compose': {
            'type': 'DialogResponsesAdapter', 'fields': {'Version': '5', 'ObjectFormat': '2'}, 'sets': [
                {'path': 'Scripts', 'verb': 'Add', 'compose': {'type': 'ScriptEntry', 'fields': {
                    'Name': '_SLSHE_TIF_IdleNext', 'Flags': 'Local'}, 'sets': [
                    {'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptObjectProperty', 'fields': {
                        'Name': name, 'Flags': 'Edited', 'Object': obj, 'Alias': '-1'}}}
                    for name, obj in (('GameDaysPassed', GAME_DAYS_PASSED), ('_SLSHE_IdleNext', idle_next),
                                      ('_SLSHE_IdleGap', idle_gap))]}},
                {'path': 'ScriptFragments.FileName', 'value': '_SLSHE_TIF_IdleNext'},
                {'path': 'ScriptFragments.ExtraBindDataVersion', 'value': '2'},
                {'path': 'ScriptFragments.OnBegin', 'compose': {'type': 'ScriptFragment', 'fields': {
                    'ScriptName': '_SLSHE_TIF_IdleNext', 'FragmentName': 'Fragment_0',
                    'ExtraBindDataVersion': '1'}}}]}})
    json.dump(ops, open(os.path.join(HERE, 'manifest_idle_cooldown.json'), 'w', encoding='utf-8'), indent=1)
    print(len(ids), 'idle lines,', len(ops), 'ops')


if __name__ == '__main__':
    main()
