# Builds the houseCARL create manifest for the toll collector's "I need an escort" branch, added to
# "SL Survival - Hopeless Escorts Dialogue.esp" (text: collector_escort_lines.md, owner-approved 2026-10-21).
# Run: python -I gen_collector.py  ->  manifest_collector.json, then housecarl_create in_place into the dialogue plugin,
# a second pass setting ColNeed/ColBye Branch to _SLSHE_ColBranch, and a fresh .seq (new Start Game Enabled quest).
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from gen_plugin import PLAYER, response  # noqa: E402

SLS = 'SL Survival.esp'
COLLECTOR_FACTION = f'00A09C:{SLS}'
SLS_MAIN = f'000D64:{SLS}'
TOLLED_GATES = f'009ED6:{SLS}'  # quest carrying _SLS_TollUtil
DIALOGUE_FOLLOWER = '0750BA:Skyrim.esm'

HELP = [
    "Help? Oh, this should be good. Go on, girl, what's the trouble?",
    "A woman asking the gate for help. Shocking. What is it?",
    "Look at that, it can talk. Quickly, I've got real work to do.",
    "Let me guess - you want out and you can't do it on your own. What else is new.",
]
GIVE = [
    "Ha! Can't even walk through a gate without a man holding your hand. Fine. I've got just the fool for you - nobody else wants him either.",
    "An escort, she says. Hey, lads, the little lady needs a minder! ... Here, take this one. He's useless, but so are you. You'll get on.",
    "You know why we don't let your kind out alone? Because of exactly this. Wait here, I'll find you something with a pulse.",
    "Free of charge, sweetheart. We pay to get rid of him. Now you're his problem and he's yours.",
    "Look at you, all big eyes and empty hands. Pathetic. Fine, I'll fetch you the town's leftovers - suits you perfectly.",
    "Gods, the begging. Alright, alright. One escort, slightly used, mostly drunk. Don't bring him back.",
    "A grown woman who can't take ten steps past a wall by herself. Skyrim really has gone soft. Here - your new keeper.",
    "Hah! Someone write this down. Fine, girl, you get the dregs. Try not to lose him before he loses you.",
]
ALREADY = [
    "You already have one, you greedy little thing. Use him.",
    "One idiot per woman. Town rule. I just made it up, but it's a rule.",
    "What, the first one ran off already? No? Then get out of my face.",
]
BYE = ["Then stop wasting my time."]


def condition(data_type, fields, value, op='EqualTo'):
    return {'field_path': 'Conditions', 'op': 'Add', 'compose': {'type': 'ConditionFloat', 'fields': {
        'CompareOperator': op, 'ComparisonValue': value}, 'sets': [{'path': 'Data', 'compose': {
            'type': data_type, 'fields': dict(fields, RunOnType='Subject')}}]}}


def at_collector():
    # spoken by a toll collector while the toll is still due (the same test as SLS's own "Pay toll" line)
    return [condition('GetInFactionConditionData', {'Faction': COLLECTOR_FACTION}, '1'),
            condition('GetVMQuestVariableConditionData', {'Quest': SLS_MAIN, 'VariableName': '::IsTollPaid_var'}, '0')]


def fragment(script, slot, props):
    # props: [(name, FormID)]; slot: OnBegin / OnEnd
    sets = [{'path': 'Scripts', 'verb': 'Add', 'compose': {'type': 'ScriptEntry', 'fields': {
        'Name': script, 'Flags': 'Local'}, 'sets': [
        {'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptObjectProperty', 'fields': {
            'Name': n, 'Flags': 'Edited', 'Object': obj, 'Alias': '-1'}}} for n, obj in props]}},
        # ScriptFragments is a polymorphic base the tool can't compose whole; its fields are set one by one
        {'path': 'ScriptFragments.FileName', 'value': script},
        {'path': 'ScriptFragments.ExtraBindDataVersion', 'value': '2'},
        {'path': f'ScriptFragments.{slot}', 'compose': {'type': 'ScriptFragment', 'fields': {
            'ScriptName': script, 'FragmentName': 'Fragment_0', 'ExtraBindDataVersion': '1'}}}]
    return {'field_path': 'VirtualMachineAdapter', 'compose': {'type': 'DialogResponsesAdapter', 'fields': {
        'Version': '5', 'ObjectFormat': '2'}, 'sets': sets}}


def lines(topic, prefix, texts, extra, goodbye=False):
    out = []
    for i, text in enumerate(texts, 1):
        ops = [response(text)] + at_collector() + extra
        if len(texts) > 1:
            ops.append({'field_path': 'Flags.Flags', 'value': ('Random, RandomEnd' if i == len(texts) else 'Random')
                        + (', Goodbye' if goodbye else '')})
        elif goodbye:
            ops.append({'field_path': 'Flags.Flags', 'value': 'Goodbye'})
        out.append({'record_type': 'DialogResponses', 'editorid': f'_SLSHE_{prefix}{i:02d}', 'parent': topic,
                    'ops': ops})
    return out


def main():
    recs = [
        {'record_type': 'GlobalShort', 'editorid': '_SLSHE_EscortAlive', 'ops': [{'field_path': 'Data', 'value': '0'}]},
        {'record_type': 'Quest', 'editorid': '_SLSHE_Col', 'ops': [
            {'field_path': 'Name', 'value': 'Hopeless Escorts Toll Collectors'},
            {'field_path': 'Flags', 'value': 'StartGameEnabled'},
            {'field_path': 'Priority', 'value': '60'},
            {'field_path': 'DialogConditions', 'op': 'Add', 'compose': {'type': 'ConditionFloat', 'fields': {
                'CompareOperator': 'EqualTo', 'ComparisonValue': '1'}, 'sets': [{'path': 'Data', 'compose': {
                    'type': 'GetIsSexConditionData', 'fields': {'MaleFemaleGender': 'Female', 'RunOnType': 'Reference',
                                                                'Reference': PLAYER}}}]}}]},
    ]
    for eid, name in (('_SLSHE_ColHelp', 'Please, I need help.'),
                      ('_SLSHE_ColNeed', "I can't leave without an escort. I need someone to go with me."),
                      ('_SLSHE_ColBye', 'Never mind.')):
        recs.append({'record_type': 'DialogTopic', 'editorid': eid, 'ops': [
            {'field_path': 'Quest', 'value': '@_SLSHE_Col'}, {'field_path': 'Subtype', 'value': 'Custom'},
            {'field_path': 'Category', 'value': 'Topic'}, {'field_path': 'Priority', 'value': '50'},
            {'field_path': 'Name', 'value': name}]})
    recs += lines('_SLSHE_ColHelp', 'ColHelp', HELP, [
        {'field_path': 'LinkTo', 'op': 'Add', 'value': '@_SLSHE_ColNeed'},
        {'field_path': 'LinkTo', 'op': 'Add', 'value': '@_SLSHE_ColBye'},
        fragment('_SLSHE_TIF_ColCheck', 'OnBegin', [('_SLSHE_EscortAlive', '@_SLSHE_EscortAlive')])])
    recs += lines('_SLSHE_ColNeed', 'ColGive', GIVE, [
        condition('GetGlobalValueConditionData', {'Global': '@_SLSHE_EscortAlive'}, '0'),
        fragment('_SLSHE_TIF_ColGive', 'OnEnd', [('DialogueFollower', DIALOGUE_FOLLOWER), ('TollUtil', TOLLED_GATES)])],
        goodbye=True)
    recs += lines('_SLSHE_ColNeed', 'ColHave', ALREADY, [
        condition('GetGlobalValueConditionData', {'Global': '@_SLSHE_EscortAlive'}, '1')], goodbye=True)
    recs += lines('_SLSHE_ColBye', 'ColBye', BYE, [], goodbye=True)
    recs.append({'record_type': 'DialogBranch', 'editorid': '_SLSHE_ColBranch', 'ops': [
        {'field_path': 'Quest', 'value': '@_SLSHE_Col'}, {'field_path': 'Category', 'value': 'Player'},
        {'field_path': 'Flags', 'value': 'TopLevel'}, {'field_path': 'StartingTopic', 'value': '@_SLSHE_ColHelp'}]})
    json.dump(recs, open(os.path.join(HERE, 'manifest_collector.json'), 'w', encoding='utf-8'), indent=1)
    print(len(recs), 'records,', sum(1 for r in recs if r['record_type'] == 'DialogResponses'), 'lines')


if __name__ == '__main__':
    main()
