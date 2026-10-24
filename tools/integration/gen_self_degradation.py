# Self-degradation variants (SLS revision, owner text 2026-10-24) into SL Survival - Revision Tweaks.esp.
# How SLS's own begging task works (SL Survival.esp, quests 01C004 _SLS_Begging / 01FC2D _SLS_BeggingSelfDegradation):
#   the begging NPC's line 01F13B (topic _SLS_BeggingNpcWants) leads into four dictation topics (_SLS_DegradationC1..C4,
#   Random INFOs, each fragment sets Init.DegradationDialogNpcChoice[step] = 1..4); the heroine then tells a stranger
#   the same four parts (topics _SLS_SelfDegradationC<step>O<n>, each listener reaction sets DegradationDialogPlayerChoice),
#   the stranger closes (01F6BC) and the begging NPC pays only if every part matched (SLS_Main.IsDegradationSuccess).
# Added here: per step new option topics with choice values 5..7 + their dictation lines (sd_dictation.csv), two random
# listener reactions each, three more openers / closings / payments as Random siblings of SLS's single lines.
# Options about animals (SD_C2_O5) are left out on purpose.
#   python -I gen_self_degradation.py create   -> manifest_sd_create.json  (housecarl_create into the plugin)
#   python -I gen_self_degradation.py apply <created.json>  -> manifest_sd_apply.json (LinkTo / flags on SLS records)
import csv
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SD = os.path.join(HERE, '..', 'self_degradation')
SLS = 'SL Survival.esp'
SKIP = ('SD_C2_O5',)

DICT_TOPIC = {1: '01F13D', 2: '01F6A3', 3: '01F6A7', 4: '01F6AB'}
DICT_NEXT = {1: '01F6A3', 2: '01F6A7', 3: '01F6AB', 4: '01F6AF'}
DICT_LAST = {1: '0201B4', 2: '020727', 3: '020728', 4: '020729'}
# SLS's own option topics per step, in the order SLS links them
OLD_TOPICS = {1: ['01E093', '01E612', '01E61C', '0201B5'], 2: ['01E094', '01E614', '01E620', '0201BB'],
              3: ['01E60E', '01E616', '01E61E', '0201B7'], 4: ['01E610', '01E618', '01E61A', '0201B9']}
# SLS INFOs that lead into step N's option menu (whose LinkTo get the new step-N topics)
INTO_STEP = {1: ['01E092', '01F6BF'], 2: ['01E095', '01E613', '01E61D', '0201B6'],
             3: ['01E096', '01E615', '01E621', '0201BC'], 4: ['01E60F', '01E617', '01E61F', '0201B8']}


def fid(x):
    return f'{x}:{SLS}'


def read_csv(name):
    rows = []
    for f in csv.reader(open(os.path.join(SD, name), encoding='utf-8')):
        if f[0] == 'id':
            head = f
            continue
        if name == 'self_degradation.csv' and len(f) == 8:  # unquoted comma in the text column
            f = f[:4] + [f[4] + ',' + f[5]] + f[6:]
        rows.append(dict(zip(head, f)))
    return {r['id']: r for r in rows if not r['id'].startswith(SKIP)}


def cond(data_type, fields, value, op='EqualTo', sets=None):
    d = {'type': data_type, 'fields': dict(fields, RunOnType='Subject')}
    if sets:
        d['sets'] = sets
    return {'type': 'ConditionFloat', 'fields': {'CompareOperator': op, 'ComparisonValue': value},
            'sets': [{'path': 'Data', 'compose': d}]}


def response(text):
    return {'field_path': 'Responses', 'op': 'Add', 'compose': {'type': 'DialogResponse', 'fields': {
        'Text': text, 'Emotion': 'Neutral', 'EmotionValue': '50', 'ResponseNumber': '1'}}}


def vmad(script, props):
    sets = []
    for name, kind, value in props:
        if kind == 'int':
            sets.append({'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptIntProperty', 'fields': {
                'Name': name, 'Flags': 'Edited', 'Data': str(value)}}})
        else:
            obj, alias = value
            sets.append({'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptObjectProperty', 'fields': {
                'Name': name, 'Flags': 'Edited', 'Object': obj, 'Alias': str(alias)}}})
    return {'field_path': 'VirtualMachineAdapter', 'compose': {'type': 'DialogResponsesAdapter', 'fields': {
        'Version': '5', 'ObjectFormat': '2'}, 'sets': [
        {'path': 'Scripts', 'verb': 'Add', 'compose': {'type': 'ScriptEntry', 'fields': {'Name': script, 'Flags': 'Local'},
                                                        'sets': sets}},
        {'path': 'ScriptFragments.FileName', 'value': script},
        {'path': 'ScriptFragments.ExtraBindDataVersion', 'value': '2'},
        {'path': 'ScriptFragments.OnBegin', 'compose': {'type': 'ScriptFragment', 'fields': {
            'ScriptName': script, 'FragmentName': 'Fragment_0', 'ExtraBindDataVersion': '1'}}}]}}


INIT = ('Init', 'obj', (fid('000D64'), -1))


def info(eid, parent, text, flags, prev, links=(), conds=(), script=None):
    ops = [response(text), {'field_path': 'Flags.Flags', 'value': flags}, {'field_path': 'PreviousDialog', 'value': prev}]
    ops += [{'field_path': 'LinkTo', 'op': 'Add', 'value': link} for link in links]
    ops += [{'field_path': 'Conditions', 'op': 'Add', 'compose': c} for c in conds]
    if script:
        ops.append(vmad(*script))
    return {'record_type': 'DialogResponses', 'editorid': eid, 'parent': parent, 'ops': ops}


def options():
    rows = read_csv('self_degradation.csv')
    out = {}
    for step in range(1, 5):
        opts = sorted(k for k, r in rows.items() if r['kind'] == 'player_option' and r['step'] == str(step))
        out[step] = [(k, rows[k]['text'], [rows[r]['text'] for r in (k + '_R1', k + '_R2') if r in rows]) for k in opts]
    return rows, out


def create():
    rows, opts = options()
    dictation = read_csv('sd_dictation.csv')
    recs = []
    # option topics first, so links can name them
    for step in range(1, 5):
        for n, (oid, text, _) in enumerate(opts[step]):
            recs.append({'record_type': 'DialogTopic', 'editorid': f'_SLSRT_SD_{oid[3:]}', 'ops': [
                {'field_path': 'Quest', 'value': fid('01FC2D')}, {'field_path': 'Branch', 'value': fid('01EB8A')},
                {'field_path': 'Subtype', 'value': 'Custom'}, {'field_path': 'Category', 'value': 'Topic'},
                {'field_path': 'Priority', 'value': '50'}, {'field_path': 'Name', 'value': text}]})
    for step in range(1, 5):
        prev = fid(DICT_LAST[step])
        for n, (oid, text, reactions) in enumerate(opts[step]):
            choice = 5 + n
            d = next(r for r in dictation.values() if r['for_option'] == oid)
            eid = f'_SLSRT_SD_D{step}_{choice}'
            recs.append(info(eid, fid(DICT_TOPIC[step]), d['text'], 'Random, InvisibleContinue', prev,
                             [fid(DICT_NEXT[step])], script=('_SLSRT_TIF_SDNpc', [('Step', 'int', step - 1), ('Choice', 'int', choice), INIT])))
            prev = '@' + eid
            topic = f'_SLSRT_SD_{oid[3:]}'
            if step < 4:
                links = [fid(x) for x in OLD_TOPICS[step + 1]] + [f'@_SLSRT_SD_{o[3:]}' for o, _, _ in opts[step + 1]]
                flags = 'Random'
            else:
                links = [fid('01F6BB')]
                flags = 'Random, Goodbye, InvisibleContinue'
            rprev = '0'
            for i, rtext in enumerate(reactions):
                reid = f'{topic}_R{i + 1}'
                recs.append(info(reid, topic, rtext, flags, rprev, links,
                                 script=('_SLSRT_TIF_SDPlayer', [('Step', 'int', step - 1), ('Choice', 'int', choice), INIT])))
                rprev = '@' + reid
    # openers: Random siblings of 01F13B in _SLS_BeggingNpcWants, same gate, chance split four ways (35% -> 9% each)
    opener_conds = [
        cond('GetGlobalValueConditionData', {'Global': fid('05A79F')}, '1'),
        cond('GetVMQuestVariableConditionData', {'Quest': fid('000D64'), 'VariableName': '::BeggingDnpcFound_var'}, '0', 'GreaterThan'),
        cond('GetRandomPercentConditionData', {}, '9', 'LessThan')]
    prev = fid('03693F')
    for k in ('SD_OPEN_01', 'SD_OPEN_02', 'SD_OPEN_03'):
        eid = f'_SLSRT_SD_Open{k[-2:]}'
        recs.append(info(eid, fid('01C578'), rows[k]['text'], 'Random, InvisibleContinue', prev, [fid('01F13D')],
                         opener_conds, ('TIF__0501F13B', [])))
        prev = '@' + eid
    # closings (the stranger): siblings of 01F6BC with its fragment
    prev = fid('01F6BC')
    for k in ('SD_END_01', 'SD_END_02', 'SD_END_03'):
        eid = f'_SLSRT_SD_End{k[-2:]}'
        recs.append(info(eid, fid('01F6BB'), rows[k]['text'], 'Random, Goodbye', prev, (), (),
                         ('TIF__0501F6BC', [INIT, ('_SLS_BeggingSelfDegradation', 'obj', (fid('01FC2D'), -1)),
                                            ('Main', 'obj', (fid('000D64'), 0))])))
        prev = '@' + eid
    # payments (the begging NPC): siblings of 01FC34
    prev = fid('01FC34')
    for k in ('SD_REW_01', 'SD_REW_02', 'SD_REW_03'):
        eid = f'_SLSRT_SD_Rew{k[-2:]}'
        recs.append(info(eid, fid('01FC33'), rows[k]['text'], 'Random, InvisibleContinue', prev, [fid('01FC37')],
                         [cond('GetIsAliasRefConditionData', {'ReferenceAliasIndex': '1'}, '1')]))
        prev = '@' + eid
    json.dump(recs, open(os.path.join(HERE, 'manifest_sd_create.json'), 'w', encoding='utf-8'), indent=1)
    print(len(recs), 'records', {s: len(opts[s]) for s in opts})


def apply(created):
    # created: {editorid: formid} of the new option topics
    _, opts = options()
    ids = json.load(open(created, encoding='utf-8'))
    ops = []
    for step in range(1, 5):
        for src in INTO_STEP[step]:
            for oid, _, _ in opts[step]:
                ops.append({'formid': fid(src), 'field_path': 'LinkTo', 'op': 'Add', 'value': ids[f'_SLSRT_SD_{oid[3:]}']})
    ops.append({'formid': fid('01F13B'), 'field_path': 'Conditions', 'op': 'SetAtIndex', 'key': '2',
                'compose': cond('GetRandomPercentConditionData', {}, '9', 'LessThan')})
    for src in ('01F6BC', '01FC34'):
        ops.append({'formid': fid(src), 'field_path': 'Flags.Flags', 'op': 'Add', 'value': 'Random'})
    json.dump(ops, open(os.path.join(HERE, 'manifest_sd_apply.json'), 'w', encoding='utf-8'), indent=1)
    print(len(ops), 'ops')


if __name__ == '__main__':
    create() if sys.argv[1] == 'create' else apply(sys.argv[2])
