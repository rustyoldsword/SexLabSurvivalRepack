# Easy-bed suitors (SLS revision pack 4, owner idea 2026-10-23): sleeping in one of SLS's "easy beds" (Jorrvaskr's
# lower floor, the College student room, the Thieves Guild bed) may wake the heroine to a man from the same room who
# wants into her bed. His proposition is the quest's Hello (it plays when sls_easybeds makes the player talk to him),
# she answers yes / for money / no; yes and money start a SexLab P+ scene through SLS's own Main.StartSexVaginal.
# Records go into SL Survival - Revision Tweaks.esp (housecarl_create into=), the quest is started by script only,
# so no .seq. Text is suggestive, not explicit.
# Run: python -I gen_suitors.py  ->  manifest_suitors.json
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SLS = 'SL Survival.esp'
PLAYER = '000014:Skyrim.esm'

OPENERS = [
    "Shh, easy... it's only me. I saw you settle in here tonight and I couldn't get you out of my head.",
    "Wake up, beautiful. A woman sleeping alone in a bed like this - people talk. I came to see if they're right about you.",
    "Cold night, warm bed, nobody watching. Seemed a shame to waste it. Move over.",
    "Don't scream. I just want some company, and you looked like you could use some too.",
]
ACCEPT = ("...Fine. Get in.", "Knew you'd see it my way.")
PAY = ("It'll cost you a hundred septims.", "A hundred? Ha. You'd better be worth every coin.")
REFUSE = ("Get out before I wake the whole hall.", "Your loss. Sleep tight, then.")


def cond(data_type, fields, value, op='EqualTo'):
    return {'type': 'ConditionFloat', 'fields': {'CompareOperator': op, 'ComparisonValue': value},
            'sets': [{'path': 'Data', 'compose': {'type': data_type, 'fields': dict(fields, RunOnType='Subject')}}]}


def add_cond(data_type, fields, value, op='EqualTo'):
    return {'field_path': 'Conditions', 'op': 'Add', 'compose': cond(data_type, fields, value, op)}


def is_suitor():
    return add_cond('GetIsAliasRefConditionData', {'ReferenceAliasIndex': '0'}, '1')


def response(text):
    return {'field_path': 'Responses', 'op': 'Add', 'compose': {'type': 'DialogResponse', 'fields': {
        'Text': text, 'Emotion': 'Happy', 'EmotionValue': '40', 'ResponseNumber': '1'}}}


def fragment(choice):
    return {'field_path': 'VirtualMachineAdapter', 'compose': {'type': 'DialogResponsesAdapter', 'fields': {
        'Version': '5', 'ObjectFormat': '2'}, 'sets': [
        {'path': 'Scripts', 'verb': 'Add', 'compose': {'type': 'ScriptEntry', 'fields': {
            'Name': '_SLS_TIF_Suitor', 'Flags': 'Local'}, 'sets': [
            {'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptIntProperty', 'fields': {
                'Name': 'Choice', 'Flags': 'Edited', 'Data': str(choice)}}},
            {'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptObjectProperty', 'fields': {
                'Name': 'Main', 'Flags': 'Edited', 'Object': f'000D64:{SLS}', 'Alias': '0'}}},
            {'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptObjectProperty', 'fields': {
                'Name': 'SuitorQuest', 'Flags': 'Edited', 'Object': '@_SLSRT_Suitor', 'Alias': '-1'}}}]}},
        {'path': 'ScriptFragments.FileName', 'value': '_SLS_TIF_Suitor'},
        {'path': 'ScriptFragments.ExtraBindDataVersion', 'value': '2'},
        {'path': 'ScriptFragments.OnEnd', 'compose': {'type': 'ScriptFragment', 'fields': {
            'ScriptName': '_SLS_TIF_Suitor', 'FragmentName': 'Fragment_0', 'ExtraBindDataVersion': '1'}}}]}}


def main():
    alias_conds = [
        cond('GetIsSexConditionData', {'MaleFemaleGender': 'Male'}, '1'),
        cond('GetIsPlayableRaceConditionData', {}, '1'),
        cond('IsChildConditionData', {}, '0'),
        cond('GetDeadConditionData', {}, '0'),
        cond('GetSleepingConditionData', {}, '0'),
        cond('GetPlayerTeammateConditionData', {}, '0'),
        cond('IsInCombatConditionData', {}, '0'),
        {'type': 'ConditionFloat', 'fields': {'CompareOperator': 'EqualTo', 'ComparisonValue': '1'},
         'sets': [{'path': 'Data', 'compose': {'type': 'GetInSameCellConditionData', 'fields': {'RunOnType': 'Subject'},
                                                'sets': [{'path': 'Target', 'value': PLAYER}]}}]},
    ]
    recs = [
        {'record_type': 'GlobalFloat', 'editorid': '_SLSRT_SuitorEnable', 'ops': [{'field_path': 'Data', 'value': '1'}]},
        {'record_type': 'GlobalFloat', 'editorid': '_SLSRT_SuitorNext', 'ops': [{'field_path': 'Data', 'value': '0'}]},
        {'record_type': 'Quest', 'editorid': '_SLSRT_Suitor', 'ops': [
            {'field_path': 'Name', 'value': 'Easy Bed Suitor'},
            {'field_path': 'Priority', 'value': '90'},
            {'field_path': 'Aliases', 'op': 'Add', 'compose': {'type': 'QuestAlias', 'fields': {
                'ID': '0', 'Name': 'Suitor', 'Type': 'Reference',
                'Flags': 'Optional, MatchingRefInLoadedArea, MatchingRefClosest'},
                'sets': [{'path': 'Conditions', 'verb': 'Add', 'compose': c} for c in alias_conds]}},
            {'field_path': 'NextAliasID', 'value': '1'}]},
        {'record_type': 'DialogTopic', 'editorid': '_SLSRT_SuitorHello', 'ops': [
            {'field_path': 'Quest', 'value': '@_SLSRT_Suitor'}, {'field_path': 'Category', 'value': 'Misc'},
            {'field_path': 'Subtype', 'value': 'Hello'}, {'field_path': 'Priority', 'value': '50'}]},
    ]
    prev = None
    for i, text in enumerate(OPENERS):
        eid = f'_SLSRT_SuitorHello{i + 1:02d}'
        ops = [response(text), is_suitor(), {'field_path': 'Flags.Flags', 'value': 'Random'}]
        if i == len(OPENERS) - 1:
            ops.append({'field_path': 'Flags.Flags', 'op': 'Add', 'value': 'RandomEnd'})
        ops.append({'field_path': 'PreviousDialog', 'value': f'@{prev}' if prev else '0'})
        recs.append({'record_type': 'DialogResponses', 'editorid': eid, 'parent': '_SLSRT_SuitorHello', 'ops': ops})
        prev = eid
    for n, (choice, (prompt, reply)) in enumerate([(0, ACCEPT), (1, PAY), (2, REFUSE)]):
        topic, branch = f'_SLSRT_SuitorAnswer{n}', f'_SLSRT_SuitorBranch{n}'
        recs.append({'record_type': 'DialogTopic', 'editorid': topic, 'ops': [
            {'field_path': 'Quest', 'value': '@_SLSRT_Suitor'}, {'field_path': 'Subtype', 'value': 'Custom'},
            {'field_path': 'Category', 'value': 'Topic'}, {'field_path': 'Priority', 'value': '50'},
            {'field_path': 'Name', 'value': prompt}]})
        recs.append({'record_type': 'DialogBranch', 'editorid': branch, 'ops': [
            {'field_path': 'Quest', 'value': '@_SLSRT_Suitor'}, {'field_path': 'Flags', 'value': 'TopLevel'},
            {'field_path': 'StartingTopic', 'value': f'@{topic}'}]})
        recs.append({'record_type': 'DialogResponses', 'editorid': f'_SLSRT_SuitorAnswer{n}_01', 'parent': topic, 'ops': [
            response(reply), is_suitor(), {'field_path': 'Flags.Flags', 'value': 'Goodbye'}, fragment(choice)]})
    json.dump(recs, open(os.path.join(HERE, 'manifest_suitors.json'), 'w', encoding='utf-8'), indent=1)
    print(len(recs), 'records')


if __name__ == '__main__':
    main()
