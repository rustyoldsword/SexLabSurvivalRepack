# Builds the houseCARL create manifest for "SL Survival - Hopeless Escorts Dialogue.esp" from lines.py and
# custom_lines.csv (the same rows the voice script uses, so line IDs match the recorded file names).
# Run: python -I gen_plugin.py  ->  manifest_dialogue.json. Voice file names are built from the quest and topic
# EditorIDs, so they are kept short (quest <= 10, topics <= 15 characters). After the create, set each player topic's
# and the intro topic's Branch to its DialogBranch (second pass), then write the .seq.
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from build_script import rows  # noqa: E402
from lines import PROMPTS  # noqa: E402

S = 'Skyrim.esm'
HE = 'SL Survival - Hopeless Escorts.esp'
PLAYER = f'000014:{S}'
BASE = {'MIL': 0x800, 'BEG': 0x801, 'SCR': 0x802, 'FRM': 0x803, 'REC': 0x804, 'WAT': 0x805}
KW = {
    'cuirass': f'06C0EC:{S}', 'clothes': f'0A8657:{S}',
    'inn': f'01CB87:{S}', 'city': f'013168:{S}', 'town': f'013166:{S}',
    'zad_lockable': '003894:Devious Devices - Assets.esm', 'zad_collar': '003DF7:Devious Devices - Assets.esm',
    'zbf_device': '00A17C:ZaZAnimationPack.esm', 'zbf_collar': '008A4E:ZaZAnimationPack.esm',
    'sls_bikini': '049867:SL Survival.esp',
    'sla_bikini': '08E854:SexLabAroused.esm', 'sla_halfnaked': '08E855:SexLabAroused.esm',
}
IDLE_ORDER = ['NAKED', 'BOUND', 'SKIMPY', 'HURT', 'TAVERN', 'TOWN', 'HELLO']  # HELLO group also holds THREAT


def cond(data_type, fields, value='1', op='EqualTo', on_player=False, or_next=False):
    sets = [{'path': 'Data', 'compose': {'type': data_type, 'fields': dict(
        fields, RunOnType='Reference' if on_player else 'Subject', **({'Reference': PLAYER} if on_player else {}))}}]
    f = {'CompareOperator': op, 'ComparisonValue': value}
    if or_next:
        f['Flags'] = 'OR'
    return {'field_path': 'Conditions', 'op': 'Add', 'compose': {'type': 'ConditionFloat', 'fields': f, 'sets': sets}}


def is_escort(code):
    return cond('GetIsIDConditionData', {'Object': f'{BASE[code]:06X}:{HE}'})


def teammate():
    return cond('GetPlayerTeammateConditionData', {})


def worn(keys, value='1'):
    keys = list(keys)
    return [cond('WornHasKeywordConditionData', {'Keyword': KW[k]}, value=value, on_player=True,
                 or_next=(value == '1' and i < len(keys) - 1)) for i, k in enumerate(keys)]


def situation(cat):
    if cat == 'NAKED':
        return worn(['cuirass', 'clothes'], value='0')
    if cat == 'BOUND':
        return worn(['zad_lockable', 'zad_collar', 'zbf_device', 'zbf_collar'])
    if cat == 'SKIMPY':
        return worn(['sls_bikini', 'sla_bikini', 'sla_halfnaked'])
    if cat == 'HURT':
        return [cond('GetActorValuePercentConditionData', {'ActorValue': 'Health'}, value='0.33', op='LessThan',
                     on_player=True)]
    if cat == 'TAVERN':
        return [cond('LocationHasKeywordConditionData', {'Keyword': KW['inn']})]
    if cat == 'TOWN':
        return [cond('LocationHasKeywordConditionData', {'Keyword': KW['city']}, or_next=True),
                cond('LocationHasKeywordConditionData', {'Keyword': KW['town']})]
    return []


def response(text):
    return {'field_path': 'Responses', 'op': 'Add', 'compose': {'type': 'DialogResponse', 'fields': {
        'Text': text, 'Emotion': 'Neutral', 'EmotionValue': '50', 'ResponseNumber': '1'}}}


def fragment(script, prop, obj):
    return {'field_path': 'VirtualMachineAdapter', 'compose': {'type': 'DialogResponsesAdapter', 'fields': {
        'Version': '5', 'ObjectFormat': '2'}, 'sets': [
        {'path': 'Scripts', 'verb': 'Add', 'compose': {'type': 'ScriptEntry', 'fields': {'Name': script, 'Flags': 'Local'},
         'sets': [{'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptObjectProperty', 'fields': {
             'Name': prop, 'Flags': 'Edited', 'Object': obj, 'Alias': '-1'}}}]}},
        # ScriptFragments is a polymorphic base the tool can't compose whole; its fields are set one by one
        {'path': 'ScriptFragments.FileName', 'value': script},
        {'path': 'ScriptFragments.ExtraBindDataVersion', 'value': '2'},
        {'path': 'ScriptFragments.OnEnd', 'compose': {'type': 'ScriptFragment', 'fields': {
            'ScriptName': script, 'FragmentName': 'Fragment_0', 'ExtraBindDataVersion': '1'}}}]}}


def main():
    lines = [(rid.split('_')[1], cat, rid, text) for rid, _, _, cat, _, text in rows()]
    recs = [
        {'record_type': 'GlobalShort', 'editorid': '_SLSHE_Comments', 'ops': [{'field_path': 'Data', 'value': '1'}]},
        {'record_type': 'Quest', 'editorid': '_SLSHE_Dlg', 'ops': [
            {'field_path': 'Name', 'value': 'Hopeless Escorts Dialogue'},
            {'field_path': 'Flags', 'value': 'StartGameEnabled'},
            {'field_path': 'Priority', 'value': '60'},
            {'field_path': 'DialogConditions', 'op': 'Add', 'compose': {'type': 'ConditionFloat', 'fields': {
                'CompareOperator': 'EqualTo', 'ComparisonValue': '1'}, 'sets': [{'path': 'Data', 'compose': {
                    'type': 'GetIsSexConditionData', 'fields': {'MaleFemaleGender': 'Female', 'RunOnType': 'Reference',
                                                                'Reference': PLAYER}}}]}},
            {'field_path': 'DialogConditions', 'op': 'Add', 'compose': {'type': 'ConditionFloat', 'fields': {
                'CompareOperator': 'EqualTo', 'ComparisonValue': '1'}, 'sets': [{'path': 'Data', 'compose': {
                    'type': 'GetGlobalValueConditionData', 'fields': {'Global': '@_SLSHE_Comments',
                                                                      'RunOnType': 'Subject'}}}]}},
        ]},
    ]

    def topic(eid, subtype, category, name=None):
        ops = [{'field_path': 'Quest', 'value': '@_SLSHE_Dlg'}, {'field_path': 'Subtype', 'value': subtype},
               {'field_path': 'Category', 'value': category}, {'field_path': 'Priority', 'value': '50'}]
        if name:
            ops.append({'field_path': 'Name', 'value': name})
        recs.append({'record_type': 'DialogTopic', 'editorid': eid, 'ops': ops})

    def infos(topic_eid, groups, extra=None):
        # groups: list of (code, cat, [(rid, text), ...]); each group is one random block
        for code, cat, items in groups:
            for i, (rid, text) in enumerate(items):
                last = i == len(items) - 1
                ops = [response(text), is_escort(code)]
                if topic_eid in ('_SLSHE_Idle', '_SLSHE_Combat', '_SLSHE_Win') or topic_eid.startswith('_SLSHE_Talk'):
                    ops.append(teammate())
                ops += situation(cat)
                if extra:
                    ops += extra(code)
                if len(items) > 1:
                    ops.append({'field_path': 'Flags.Flags', 'value': 'Random, RandomEnd' if last else 'Random'})
                recs.append({'record_type': 'DialogResponses', 'editorid': f'_SLSHE_{rid}', 'parent': topic_eid,
                             'ops': ops})

    def grouped(cats):
        out = []
        for cat in cats:
            for code in BASE:
                items = [(rid, t) for c, k, rid, t in lines if c == code and (k == cat or (cat == 'HELLO' and k == 'THREAT'))]
                if items:
                    out.append((code, cat, items))
        return out

    topic('_SLSHE_Idle', 'Idle', 'Misc')
    infos('_SLSHE_Idle', grouped(IDLE_ORDER))
    topic('_SLSHE_Combat', 'NormalToCombat', 'Detection')
    infos('_SLSHE_Combat', grouped(['COMBAT']))
    topic('_SLSHE_Win', 'CombatToNormal', 'Detection')
    infos('_SLSHE_Win', grouped(['WIN']))
    topic('_SLSHE_Intro', 'Custom', 'Misc')
    infos('_SLSHE_Intro', grouped(['INTRO']))

    # player choices: TALK n answers PROMPTS[n-1]; the last prompt is answered by DISMISS
    talk = {code: [(rid, t) for c, k, rid, t in lines if c == code and k == 'TALK'] for code in BASE}
    for n, prompt in enumerate(PROMPTS, 1):
        teid = f'_SLSHE_Talk{n}'
        topic(teid, 'Custom', 'Topic', name=prompt)
        dismiss = n == len(PROMPTS)
        for code in BASE:
            if dismiss:
                rid, text = next((rid, t) for c, k, rid, t in lines if c == code and k == 'DISMISS')
            else:
                rid, text = talk[code][n - 1]
            ops = [response(text), is_escort(code), teammate()]
            if prompt.startswith('Here, take some coin'):
                ops.append(cond('GetItemCountConditionData', {'ItemOrList': f'00000F:{S}'}, value='50',
                                op='GreaterThanOrEqualTo', on_player=True))
                ops.append(fragment('_SLSHE_TIF_Coin', 'Gold001', f'00000F:{S}'))
            if dismiss:
                ops.append({'field_path': 'Flags.Flags', 'value': 'Goodbye'})
                ops.append(fragment('_SLSHE_TIF_Dismiss', 'DialogueFollower', f'0750BA:{S}'))
            recs.append({'record_type': 'DialogResponses', 'editorid': f'_SLSHE_{rid}', 'parent': teid, 'ops': ops})
        recs.append({'record_type': 'DialogBranch', 'editorid': f'_SLSHE_Talk{n}Branch', 'ops': [
            {'field_path': 'Quest', 'value': '@_SLSHE_Dlg'}, {'field_path': 'Category', 'value': 'Player'},
            {'field_path': 'Flags', 'value': 'TopLevel'}, {'field_path': 'StartingTopic', 'value': f'@{teid}'}]})

    # the intro topic is said from script, but the CK needs a branch on it too (created last, keeps FormIDs stable)
    recs.append({'record_type': 'DialogBranch', 'editorid': '_SLSHE_IntroBranch', 'ops': [
        {'field_path': 'Quest', 'value': '@_SLSHE_Dlg'}, {'field_path': 'Category', 'value': 'Player'},
        {'field_path': 'Flags', 'value': '0'}, {'field_path': 'StartingTopic', 'value': '@_SLSHE_Intro'}]})
    json.dump(recs, open(os.path.join(HERE, 'manifest_dialogue.json'), 'w', encoding='utf-8'), indent=1)
    print(len(recs), 'records,', sum(1 for r in recs if r['record_type'] == 'DialogResponses'), 'lines')


if __name__ == '__main__':
    main()
