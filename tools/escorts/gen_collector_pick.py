# Toll collector escort pick list (owner request 2026-10-23): instead of a random escort, the collector's "I need an
# escort" answers (_SLSHE_ColGive01..08) lead to six player choices, one per hopeless escort, and the answer to the
# choice spawns that escort (_SLSHE_TIF_ColPick, Choice = index into _SLSHE_EscortBases).
# Run: python -I gen_collector_pick.py  ->  manifest_collector_pick.json (housecarl_create in_place into the dialogue
# plugin), then housecarl_apply of the printed GIVE edits: drop their VMAD and Goodbye flag, LinkTo the six choices.
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from gen_collector import DIALOGUE_FOLLOWER, TOLLED_GATES, at_collector, condition  # noqa: E402
from gen_plugin import response  # noqa: E402

COL_QUEST = '000DA3:SL Survival - Hopeless Escorts Dialogue.esp'   # _SLSHE_Col (filled in by main from the plugin)
ESCORT_ALIVE = None

PICKS = [  # (player choice, collector reply) in _SLSHE_EscortBases order
    ("The drunk militiaman.", "The drunk? Ha. He'll fall over before you do. Off you go, the pair of you."),
    ("The town beggar.", "The beggar. Fitting - you two can fight over the scraps."),
    ("The scribe's apprentice.", "The bookworm? He's never held anything heavier than a quill. Enjoy."),
    ("The farmhand.", "The farmhand. Strong back, empty head. A perfect match for you."),
    ("The frightened recruit.", "The recruit? He jumps at his own shadow. You'll get on famously."),
    ("The retired watchman.", "Old Watchman? Thirty years in the Watch and still useless. He's all yours."),
]


def pick_fragment(i):
    obj = lambda n, v: {'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptObjectProperty', 'fields': {
        'Name': n, 'Flags': 'Edited', 'Object': v, 'Alias': '-1'}}}
    sets = [{'path': 'Scripts', 'verb': 'Add', 'compose': {'type': 'ScriptEntry', 'fields': {
        'Name': '_SLSHE_TIF_ColPick', 'Flags': 'Local'}, 'sets': [
        {'path': 'Properties', 'verb': 'Add', 'compose': {'type': 'ScriptIntProperty', 'fields': {
            'Name': 'Choice', 'Flags': 'Edited', 'Data': str(i)}}},
        obj('DialogueFollower', DIALOGUE_FOLLOWER), obj('TollUtil', TOLLED_GATES)]}},
        {'path': 'ScriptFragments.FileName', 'value': '_SLSHE_TIF_ColPick'},
        {'path': 'ScriptFragments.ExtraBindDataVersion', 'value': '2'},
        {'path': 'ScriptFragments.OnEnd', 'compose': {'type': 'ScriptFragment', 'fields': {
            'ScriptName': '_SLSHE_TIF_ColPick', 'FragmentName': 'Fragment_0', 'ExtraBindDataVersion': '1'}}}]
    return {'field_path': 'VirtualMachineAdapter', 'compose': {'type': 'DialogResponsesAdapter', 'fields': {
        'Version': '5', 'ObjectFormat': '2'}, 'sets': sets}}


def main(col_quest, escort_alive):
    recs = []
    for i, (choice, reply) in enumerate(PICKS):
        topic = f'_SLSHE_ColPick{i}'
        recs.append({'record_type': 'DialogTopic', 'editorid': topic, 'ops': [
            {'field_path': 'Quest', 'value': col_quest}, {'field_path': 'Subtype', 'value': 'Custom'},
            {'field_path': 'Category', 'value': 'Topic'}, {'field_path': 'Priority', 'value': '50'},
            {'field_path': 'Name', 'value': choice}]})
        recs.append({'record_type': 'DialogResponses', 'editorid': f'_SLSHE_ColPick{i}_01', 'parent': topic, 'ops': [
            response(reply)] + at_collector() + [
            condition('GetGlobalValueConditionData', {'Global': escort_alive}, '0'),
            {'field_path': 'Flags.Flags', 'value': 'Goodbye'}, pick_fragment(i)]})
    json.dump(recs, open(os.path.join(HERE, 'manifest_collector_pick.json'), 'w', encoding='utf-8'), indent=1)
    print(len(recs), 'records')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
