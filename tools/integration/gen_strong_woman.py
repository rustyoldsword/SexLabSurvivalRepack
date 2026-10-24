# Mjoll's "A Woman of Strength" (SLS revision pack 4, owner idea 2026-10-23): a way for the heroine to throw off SLS's
# gender inequality. Mjoll sets three trials - kill fifteen people who prey on others, live seven days without an
# armor licence, master a weapon or Destruction to 50 - tracked by _SLSRT_StrongWomanQuest; afterwards
# sls_mcm.GrantStrongWoman puts her in SLS's strong female faction and drops the inequality perks.
# The opening topic hangs on SLS's always-running main quest (no .seq needed); the quest itself starts from it.
# Run: python -I gen_strong_woman.py  ->  manifest_strong_woman.json (housecarl_create into Revision Tweaks)
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SLS = 'SL Survival.esp'
MJOLL = '01336B:Skyrim.esm'
PLAYER = '000014:Skyrim.esm'
QUEST = '@_SLSRT_StrongWoman'

START = ("Mjoll, the laws here treat women like property. How do I prove them wrong?",
         "Prove it to yourself first, and the rest of Skyrim will follow. Three trials. Spill the blood of fifteen "
         "who prey on the weak. Live seven days without begging a clerk for an armor licence. And master a blade, "
         "a bow or the fire of Destruction until it answers you without thought. Come back when it's done.")
PROGRESS = ("About the trials...", "Not done yet. A Nord finishes what she starts. Go on.")
DONE = ("It's done. All three trials.",
        "I can see it in the way you stand. You're no one's property, and anyone who says otherwise can tell it to "
        "your blade. Walk tall, sister.")
OBJECTIVES = [(10, 'Kill fifteen people who prey on others'),
              (20, 'Live seven days without an armor licence'),
              (30, 'Reach 50 in One-Handed, Two-Handed, Archery or Destruction'),
              (40, 'Return to Mjoll')]
STAGES = [(10, "Mjoll the Lioness told me that if I want to be more than property in Skyrim, I have to prove it to "
               "myself first. She set me three trials."),
          (40, "I have passed all three of Mjoll's trials. I should return to her in Riften."),
          (100, "Mjoll declared me a woman of strength. The laws of men no longer hold me down.")]


def cond_data(data_type, fields, value, op='EqualTo', on_player=False, sets=None):
    f = dict(fields)
    if on_player:
        f.update(RunOnType='Reference', Reference=PLAYER)
    else:
        f.update(RunOnType='Subject')
    d = {'type': data_type, 'fields': f}
    if sets:
        d['sets'] = sets
    return {'type': 'ConditionFloat', 'fields': {'CompareOperator': op, 'ComparisonValue': value},
            'sets': [{'path': 'Data', 'compose': d}]}


def add(c):
    return {'field_path': 'Conditions', 'op': 'Add', 'compose': c}


def is_mjoll():
    return add(cond_data('GetIsIDConditionData', {'Object': MJOLL}, '1'))


def stage_is(value, op):
    return add(cond_data('GetStageConditionData', {'Quest': QUEST}, value, op))


def response(text):
    return {'field_path': 'Responses', 'op': 'Add', 'compose': {'type': 'DialogResponse', 'fields': {
        'Text': text, 'Emotion': 'Neutral', 'EmotionValue': '50', 'ResponseNumber': '1'}}}


def fragment(choice):
    return {'field_path': 'VirtualMachineAdapter', 'compose': {'type': 'DialogResponsesAdapter', 'fields': {
        'Version': '5', 'ObjectFormat': '2'}, 'sets': [
        {'path': 'Scripts', 'verb': 'Add', 'compose': {'type': 'ScriptEntry', 'fields': {
            'Name': '_SLS_TIF_StrongWoman', 'Flags': 'Local'}, 'sets': [
            {'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptIntProperty', 'fields': {
                'Name': 'Choice', 'Flags': 'Edited', 'Data': str(choice)}}},
            {'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptObjectProperty', 'fields': {
                'Name': 'StrongQuest', 'Flags': 'Edited', 'Object': QUEST, 'Alias': '-1'}}},
            {'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptObjectProperty', 'fields': {
                'Name': 'Menu', 'Flags': 'Edited', 'Object': f'000D64:{SLS}', 'Alias': '-1'}}}]}},
        {'path': 'ScriptFragments.FileName', 'value': '_SLS_TIF_StrongWoman'},
        {'path': 'ScriptFragments.ExtraBindDataVersion', 'value': '2'},
        {'path': 'ScriptFragments.OnEnd', 'compose': {'type': 'ScriptFragment', 'fields': {
            'ScriptName': '_SLS_TIF_StrongWoman', 'FragmentName': 'Fragment_0', 'ExtraBindDataVersion': '1'}}}]}}


def topic(eid, quest, prompt):
    return {'record_type': 'DialogTopic', 'editorid': eid, 'ops': [
        {'field_path': 'Quest', 'value': quest}, {'field_path': 'Subtype', 'value': 'Custom'},
        {'field_path': 'Category', 'value': 'Topic'}, {'field_path': 'Priority', 'value': '50'},
        {'field_path': 'Name', 'value': prompt}]}


def branch(eid, quest, start):
    return {'record_type': 'DialogBranch', 'editorid': eid, 'ops': [
        {'field_path': 'Quest', 'value': quest}, {'field_path': 'Flags', 'value': 'TopLevel'},
        {'field_path': 'StartingTopic', 'value': f'@{start}'}]}


def main():
    quest_ops = [
        {'field_path': 'Name', 'value': 'A Woman of Strength'},
        {'field_path': 'Priority', 'value': '60'},
        {'field_path': 'Type', 'value': 'Misc'},
        {'field_path': 'Aliases', 'op': 'Add', 'compose': {'type': 'QuestAlias', 'fields': {
            'ID': '0', 'Name': 'Mjoll', 'Type': 'Reference', 'UniqueActor': MJOLL, 'Flags': 'Optional'}}},
        {'field_path': 'NextAliasID', 'value': '1'},
        {'field_path': 'VirtualMachineAdapter', 'compose': {'type': 'QuestAdapter', 'fields': {
            'Version': '5', 'ObjectFormat': '2'}, 'sets': [
            {'path': 'Scripts', 'verb': 'Add', 'compose': {'type': 'ScriptEntry', 'fields': {
                'Name': '_SLSRT_StrongWomanQuest', 'Flags': 'Local'}}}]}},
    ]
    for idx, text in STAGES:
        quest_ops.append({'field_path': 'Stages', 'op': 'Add', 'compose': {'type': 'QuestStage', 'fields': {
            'Index': str(idx)}, 'sets': [{'path': 'LogEntries', 'verb': 'Add', 'compose': {
                'type': 'QuestLogEntry', 'sets': [{'path': 'Entry', 'value': text}]}}]}})
    for idx, text in OBJECTIVES:
        obj = {'type': 'QuestObjective', 'fields': {'Index': str(idx)}, 'sets': [{'path': 'DisplayText', 'value': text}]}
        if idx == 40:
            obj['sets'].append({'path': 'Targets', 'verb': 'Add', 'compose': {'type': 'QuestObjectiveTarget',
                                                                               'fields': {'AliasID': '0'}}})
        quest_ops.append({'field_path': 'Objectives', 'op': 'Add', 'compose': obj})

    recs = [{'record_type': 'Quest', 'editorid': '_SLSRT_StrongWoman', 'ops': quest_ops}]
    # opening line on SLS's main quest (always running)
    recs.append(topic('_SLSRT_StrongStart', f'000D64:{SLS}', START[0]))
    recs.append(branch('_SLSRT_StrongStartBranch', f'000D64:{SLS}', '_SLSRT_StrongStart'))
    recs.append({'record_type': 'DialogResponses', 'editorid': '_SLSRT_StrongStart01', 'parent': '_SLSRT_StrongStart', 'ops': [
        response(START[1]), is_mjoll(), stage_is('0', 'EqualTo'),
        add(cond_data('GetIsSexConditionData', {'MaleFemaleGender': 'Female'}, '1', on_player=True)),
        add(cond_data('GetInFactionConditionData', {'Faction': f'0A7DA4:{SLS}'}, '0', on_player=True)),
        add(cond_data('GetGlobalValueConditionData', {'Global': f'070258:{SLS}'}, '1')),
        {'field_path': 'Flags.Flags', 'value': 'Goodbye'}, fragment(0)]})
    for eid, (prompt, reply), lo, hi, choice in [
            ('_SLSRT_StrongProgress', PROGRESS, '10', '40', None),
            ('_SLSRT_StrongDone', DONE, '40', None, 1)]:
        recs.append(topic(eid, QUEST, prompt))
        recs.append(branch(eid + 'Branch', QUEST, eid))
        ops = [response(reply), is_mjoll()]
        if hi:
            ops += [stage_is(lo, 'GreaterThanOrEqualTo'), stage_is(hi, 'LessThan')]
        else:
            ops += [stage_is(lo, 'EqualTo')]
        ops.append({'field_path': 'Flags.Flags', 'value': 'Goodbye'})
        if choice is not None:
            ops.append(fragment(choice))
        recs.append({'record_type': 'DialogResponses', 'editorid': eid + '01', 'parent': eid, 'ops': ops})
    json.dump(recs, open(os.path.join(HERE, 'manifest_strong_woman.json'), 'w', encoding='utf-8'), indent=1)
    print(len(recs), 'records')


if __name__ == '__main__':
    main()
