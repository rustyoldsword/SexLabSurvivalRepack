# Whore licence duties (owner idea 2026-10-24, plan audit\SLS Framework\WHORE-LICENCE-DUTIES-RU.md) for
# SL Survival - Revision Tweaks.esp: clients approach a licensed heroine, a refusal turns into a report to the town
# guard, the guard revokes the licence, fines and punishes, and the licence office will not sell a new one for a while.
# Texts here are plain placeholders for the owner to rewrite and voice.
#   python -I gen_whore_duties.py create            -> manifest_wl_create.json (housecarl_create into the plugin)
#   python -I gen_whore_duties.py apply <ids.json>  -> manifest_wl_apply.json (packages, licence-office conditions)
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SLS = 'SL Survival.esp'
P = 'SL Survival - Revision Tweaks.esp'
PLAYER = '000014:Skyrim.esm'
GLOBALS = [('_SLSRT_WL_Enable', 'GlobalShort', '1'), ('_SLSRT_WL_Chance', 'GlobalFloat', '30'),
           ('_SLSRT_WL_Gap', 'GlobalFloat', '3'), ('_SLSRT_WL_Pay', 'GlobalShort', '100'),
           ('_SLSRT_WL_Fine', 'GlobalShort', '200'), ('_SLSRT_WL_BanDays', 'GlobalFloat', '7'),
           ('_SLSRT_WL_Banned', 'GlobalShort', '0')]
CLIENT_OPEN = ["You're the girl with the licence, aren't you? I've got coin and a free hour. What do you say?",
               "Word is you're working. Good. I'm buying.",
               "Hold on, sweetheart. That licence means you're open for business, right? I'm your next customer."]
CLIENT_ANS = [("Sure. Pay up and follow me.", "Now that's service."),
              ("Not today. Find someone else.", "Not today? You're licensed, girl. The guards will hear about this."),
              ("Get lost, creep.", "Big mistake. Let's see what the guards say about a licensed girl who turns away paying customers.")]
GUARD_OPEN = ["There you are. A citizen says you turned him away. That licence comes with obligations.",
              "Hold it. We've had a complaint about you refusing a paying customer."]
GUARD_ANS = [("I'm sorry. It won't happen again.", "Sorry won't cut it. Hand over the licence, and the fine."),
             ("He was a creep. I can refuse whoever I want.", "Not with that licence you can't. Licence revoked, fine paid - and a lesson on top.")]


def c(data_type, fields, value, op='EqualTo', target=None):
    d = {'type': data_type, 'fields': dict(fields, RunOnType='Subject')}
    if target:
        d['sets'] = [{'path': 'Target', 'value': target}]
    return {'type': 'ConditionFloat', 'fields': {'CompareOperator': op, 'ComparisonValue': value},
            'sets': [{'path': 'Data', 'compose': d}]}


def alias(name, conds, flags='Optional, MatchingRefInLoadedArea, MatchingRefClosest'):
    return {'field_path': 'Aliases', 'op': 'Add', 'compose': {'type': 'QuestAlias', 'fields': {
        'ID': '0', 'Name': name, 'Type': 'Reference', 'Flags': flags},
        'sets': [{'path': 'Conditions', 'verb': 'Add', 'compose': x} for x in conds]}}


def quest_vmad(script):
    return {'field_path': 'VirtualMachineAdapter', 'compose': {'type': 'QuestAdapter', 'fields': {
        'Version': '5', 'ObjectFormat': '2'}, 'sets': [{'path': 'Scripts', 'verb': 'Add', 'compose': {
            'type': 'ScriptEntry', 'fields': {'Name': script, 'Flags': 'Local'}}}]}}


def frag(script, choice):
    return {'field_path': 'VirtualMachineAdapter', 'compose': {'type': 'DialogResponsesAdapter', 'fields': {
        'Version': '5', 'ObjectFormat': '2'}, 'sets': [
        {'path': 'Scripts', 'verb': 'Add', 'compose': {'type': 'ScriptEntry', 'fields': {'Name': script, 'Flags': 'Local'},
         'sets': [{'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptIntProperty', 'fields': {
             'Name': 'Choice', 'Flags': 'Edited', 'Data': str(choice)}}}]}},
        {'path': 'ScriptFragments.FileName', 'value': script},
        {'path': 'ScriptFragments.ExtraBindDataVersion', 'value': '2'},
        {'path': 'ScriptFragments.OnEnd', 'compose': {'type': 'ScriptFragment', 'fields': {
            'ScriptName': script, 'FragmentName': 'Fragment_0', 'ExtraBindDataVersion': '1'}}}]}}


def response(text):
    return {'field_path': 'Responses', 'op': 'Add', 'compose': {'type': 'DialogResponse', 'fields': {
        'Text': text, 'Emotion': 'Neutral', 'EmotionValue': '50', 'ResponseNumber': '1'}}}


def is_alias0():
    return {'field_path': 'Conditions', 'op': 'Add', 'compose': c('GetIsAliasRefConditionData', {'ReferenceAliasIndex': '0'}, '1')}


def dialogue(prefix, quest, openers, answers, script):
    recs = [{'record_type': 'DialogTopic', 'editorid': f'{prefix}Greet', 'ops': [
                {'field_path': 'Quest', 'value': quest}, {'field_path': 'Subtype', 'value': 'ForceGreet'},
                {'field_path': 'Category', 'value': 'Topic'}, {'field_path': 'Priority', 'value': '50'}]},
            {'record_type': 'DialogBranch', 'editorid': f'{prefix}Branch', 'ops': [
                {'field_path': 'Quest', 'value': quest}, {'field_path': 'Flags', 'value': 'TopLevel'},
                {'field_path': 'StartingTopic', 'value': f'@{prefix}Greet'}]}]
    for n, (prompt, _) in enumerate(answers):
        recs.append({'record_type': 'DialogTopic', 'editorid': f'{prefix}Ans{n}', 'ops': [
            {'field_path': 'Quest', 'value': quest}, {'field_path': 'Branch', 'value': f'@{prefix}Branch'},
            {'field_path': 'Subtype', 'value': 'Custom'}, {'field_path': 'Category', 'value': 'Topic'},
            {'field_path': 'Priority', 'value': '50'}, {'field_path': 'Name', 'value': prompt}]})
    prev = '0'
    for n, text in enumerate(openers):
        eid = f'{prefix}Greet{n + 1:02d}'
        ops = [response(text), is_alias0(), {'field_path': 'Flags.Flags', 'value': 'Random'},
               {'field_path': 'PreviousDialog', 'value': prev}]
        ops += [{'field_path': 'LinkTo', 'op': 'Add', 'value': f'@{prefix}Ans{i}'} for i in range(len(answers))]
        recs.append({'record_type': 'DialogResponses', 'editorid': eid, 'parent': f'{prefix}Greet', 'ops': ops})
        prev = '@' + eid
    for n, (_, reply) in enumerate(answers):
        recs.append({'record_type': 'DialogResponses', 'editorid': f'{prefix}Ans{n}_01', 'parent': f'{prefix}Ans{n}', 'ops': [
            response(reply), is_alias0(), {'field_path': 'Flags.Flags', 'value': 'Goodbye'}, frag(script, n)]})
    return recs


def create():
    recs = [{'record_type': t, 'editorid': e, 'ops': [{'field_path': 'Data', 'value': v}]} for e, t, v in GLOBALS]
    recs.append({'record_type': 'Quest', 'editorid': '_SLSRT_WL_Duty', 'ops': [
        {'field_path': 'Name', 'value': 'Whore Licence Duties'}, {'field_path': 'Priority', 'value': '40'},
        {'field_path': 'Flags', 'value': 'StartGameEnabled'}, quest_vmad('_SLSRT_WL_Duty')]})
    client = [c('GetIsSexConditionData', {'MaleFemaleGender': 'Male'}, '1'),
              c('GetIsPlayableRaceConditionData', {}, '1'), c('IsChildConditionData', {}, '0'),
              c('GetDeadConditionData', {}, '0'), c('IsGuardConditionData', {}, '0'),
              c('GetPlayerTeammateConditionData', {}, '0'), c('IsInCombatConditionData', {}, '0'),
              c('GetSleepingConditionData', {}, '0'),
              c('GetDistanceConditionData', {}, '3000', 'LessThan', PLAYER),
              c('GetInFactionConditionData', {'Faction': '00E50F:SexLab.esm'}, '0')]
    recs.append({'record_type': 'Quest', 'editorid': '_SLSRT_WL_Client', 'ops': [
        {'field_path': 'Name', 'value': 'Whore Licence Client'}, {'field_path': 'Priority', 'value': '70'},
        alias('Client', client), {'field_path': 'NextAliasID', 'value': '1'},
        quest_vmad('_SLSRT_WL_ClientQuest')]})
    guard = [c('IsGuardConditionData', {}, '1'), c('GetDeadConditionData', {}, '0'),
             c('IsInCombatConditionData', {}, '0'), c('GetDistanceConditionData', {}, '4000', 'LessThan', PLAYER),
             c('GetInFactionConditionData', {'Faction': '00E50F:SexLab.esm'}, '0')]
    recs.append({'record_type': 'Quest', 'editorid': '_SLSRT_WL_Guard', 'ops': [
        {'field_path': 'Name', 'value': 'Whore Licence Report'}, {'field_path': 'Priority', 'value': '70'},
        alias('Guard', guard), {'field_path': 'NextAliasID', 'value': '1'}, quest_vmad('_SLSRT_WL_GuardQuest')]})
    recs += dialogue('_SLSRT_WL_Client', '@_SLSRT_WL_Client', CLIENT_OPEN, CLIENT_ANS, '_SLSRT_TIF_WLClient')
    recs += dialogue('_SLSRT_WL_Guard', '@_SLSRT_WL_Guard', GUARD_OPEN, GUARD_ANS, '_SLSRT_TIF_WLGuard')
    json.dump(recs, open(os.path.join(HERE, 'manifest_wl_create.json'), 'w', encoding='utf-8'), indent=1)
    print(len(recs), 'records')


def apply(ids_file):
    ids = json.load(open(ids_file, encoding='utf-8'))
    ops = []
    for pack, topic, quest_alias in (('000856', '_SLSRT_WL_ClientGreet', '_SLSRT_WL_Client'),
                                     ('000857', '_SLSRT_WL_GuardGreet', '_SLSRT_WL_Guard')):
        pid = f'{pack}:{P}'
        ops.append({'formid': pid, 'field_path': 'Conditions', 'op': 'ReplaceAll', 'composes': []})
        ops.append({'formid': pid, 'field_path': 'Data[7].Topics', 'op': 'SetAtIndex', 'key': '0',
                    'compose': {'type': 'TopicReference', 'fields': {'Reference': ids[topic]}}})
        ops.append({'formid': ids[quest_alias], 'field_path': 'Aliases[0].PackageData', 'op': 'Add', 'value': pid})
    # no whore licence for sale while banned: licence office + the kennel keeper's two offers
    for info in ('0D09EC', '10F82B', '114937'):
        ops.append({'formid': f'{info}:{SLS}', 'field_path': 'Conditions', 'op': 'Add',
                    'compose': {'type': 'ConditionFloat', 'fields': {'CompareOperator': 'EqualTo', 'ComparisonValue': '0'},
                                'sets': [{'path': 'Data', 'compose': {'type': 'GetGlobalValueConditionData', 'fields': {
                                    'RunOnType': 'Subject', 'Global': ids['_SLSRT_WL_Banned']}}}]}})
    json.dump(ops, open(os.path.join(HERE, 'manifest_wl_apply.json'), 'w', encoding='utf-8'), indent=1)
    print(len(ops), 'ops')


if __name__ == '__main__':
    create() if sys.argv[1] == 'create' else apply(sys.argv[2])
