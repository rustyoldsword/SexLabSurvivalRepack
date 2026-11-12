# 3.0.2 stage 4: every wait that depended on another script or on the world gets a ceiling (cold audit 2026-10-31,
# ROBUSTNESS section 2). A flag left set by a save taken mid-operation, or a door another mod keeps shut, used to hold
# the script forever. Idempotent source edit; integration files in work\SLS_integration\src, framework files in
# work\SLSFramework\papyrus\source.
import sys

INT = r'C:\Modding\MO2\work\SLS_integration\src'
FW = r'C:\Modding\MO2\work\SLSFramework\papyrus\source'


def edit(path, pairs, marker):
    t = open(path, encoding='utf-8', errors='surrogateescape', newline='').read()
    nl = '\r\n' if '\r\n' in t else '\n'
    if marker in t:
        print(f'{path.split(chr(92))[-1]}: already patched')
        return
    for old, new in pairs:
        old, new = old.replace('\n', nl), new.replace('\n', nl)
        n = t.count(old)
        if n < 1:
            sys.exit(f'{path}: anchor missing: {old[:70]!r}')
        t = t.replace(old, new)
    open(path, 'w', encoding='utf-8', errors='surrogateescape', newline='').write(t)
    print(f'{path.split(chr(92))[-1]}: patched')


# cum effect spells: InProc survives a save taken during the 1 s wait inside BeginEffect
edit(INT + r'\_sls_cumeffects.psc', [(
    '\tWhile InProc\n\t\tUtility.Wait(1.0)\n\tEndWhile\n',
    '\tInt Waited = 0\n\tWhile InProc && Waited < 30 ; 3.0.2: a save taken mid-effect left InProc set forever\n'
    '\t\tUtility.Wait(1.0)\n\t\tWaited += 1\n\tEndWhile\n')], '3.0.2: a save taken mid-effect')

# guard-warning / quest chain: Stop() every 0.01 s until the quest stops, with no way out
edit(INT + r'\_sls_chainquests.psc', [
    ('\t\tWhile QuestToStopAsQuest.IsRunning()\n\t\t\tQuestToStopAsQuest.Stop()\n\t\t\tUtility.Wait(0.01)\n\t\tEndWhile\n',
     '\t\tInt Tries = 0\n\t\tWhile QuestToStopAsQuest.IsRunning() && Tries < 150 ; 3.0.2: 15 s, then go on (used to wait forever)\n'
     '\t\t\tQuestToStopAsQuest.Stop()\n\t\t\tUtility.Wait(0.1)\n\t\t\tTries += 1\n\t\tEndWhile\n'),
    ('\t\tWhile QuestToStopAsQuest.IsRunning()\n\t\t\tQuestToStopAsQuest.Stop()\n\t\t\tUtility.Wait(0.2)\n\t\tEndWhile\n',
     '\t\tInt Tries = 0\n\t\tWhile QuestToStopAsQuest.IsRunning() && Tries < 75 ; 3.0.2: 15 s, then go on\n'
     '\t\t\tQuestToStopAsQuest.Stop()\n\t\t\tUtility.Wait(0.2)\n\t\t\tTries += 1\n\t\tEndWhile\n')],
    '3.0.2: 15 s, then go on (used')

# eviction while sleeping: waits for the player to leave through the door; a locked or disabled door kept the
# fragment polling forever and EvictionSleepTrack.CleanUp() (which gives the controls back) never ran
for frag in ('tif__08026e0e', 'tif__08026e11'):
    edit(INT + '\\' + frag + '.psc', [(
        'While _SLS_PlayerSleepMarker.GetCurrentLocation().IsSameLocation(PlayerRef.GetCurrentLocation())\n'
        '\tUtility.Wait(0.1)\nEndWhile\n',
        'Int Tries = 0 ; 3.0.2: 20 s at most, then clean up anyway (a door another mod keeps shut held this forever)\n'
        'While _SLS_PlayerSleepMarker.GetCurrentLocation().IsSameLocation(PlayerRef.GetCurrentLocation()) && Tries < 200\n'
        '\tUtility.Wait(0.1)\n\tTries += 1\nEndWhile\n')], '3.0.2: 20 s at most')

# animal friends: an actor left in InProcFriends (save mid-change, actor died) blocked every later change of that actor
edit(FW + r'\_SLS_AnimalFriend.psc', [(
    '\tWhile StorageUtil.FormListFind(Self, "InProcFriends", akActor) > -1\n\t\tUtility.Wait(3.0)\n\tEndWhile\n',
    '\tInt Tries = 0\n\tWhile StorageUtil.FormListFind(Self, "InProcFriends", akActor) > -1 && Tries < 10 ; 3.0.2: 30 s, then take over\n'
    '\t\tUtility.Wait(3.0)\n\t\tTries += 1\n\tEndWhile\n')], '3.0.2: 30 s, then take over')

# bikini curse: IsInMenu is cleared only by OnMenuClose, which a save in a menu loses
edit(FW + r'\_SLS_LicBikiniCurse.psc', [(
    '\t\tWhile IsInMenu\n\t\t\tUtility.Wait(2.0)\n\t\tEndWhile\n',
    '\t\tWhile IsInMenu && Utility.IsInMenuMode() ; 3.0.2: a lost OnMenuClose (save in a menu) kept IsInMenu set forever\n'
    '\t\t\tUtility.Wait(2.0)\n\t\tEndWhile\n\t\tIsInMenu = false\n')], 'a lost OnMenuClose')
