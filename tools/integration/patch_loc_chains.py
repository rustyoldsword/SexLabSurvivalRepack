# 3.0.2 stage 4: untangle the location chain (cold audit 2026-10-31, ROBUSTNESS I4/I5).
#
# _SLS_LocTrackCentral.PlayerLocChange used to call _SLS_Curfew and _SLS_LicTownCheck directly while holding its own
# lock, and both of those read LocTrack back (TownCheck after a 2 s Wait). Location change events arrive in pairs
# (OnLocationChange + tracker OnCellAttach), so a second change could wedge the two scripts against each other - the
# stacks of _SLS_LocTrackCentral that queued up on 2026-10-30. Now LocTrack only records the town and sends mod
# events; Curfew and TownCheck react on their own threads. Curfew asks the DLL for the gate recheck instead of calling
# _SLS_TollUtil (I5). Idempotent source edit of work\SLS_integration\src.
import sys

SRC = r'C:\Modding\MO2\work\SLS_integration\src'


def load(name):
    t = open(f'{SRC}\\{name}', encoding='utf-8', errors='surrogateescape', newline='').read()
    return t, ('\r\n' if '\r\n' in t else '\n')


def save(name, t):
    open(f'{SRC}\\{name}', 'w', encoding='utf-8', errors='surrogateescape', newline='').write(t)


def rep(t, old, new, name):
    if t.count(old) != 1:
        sys.exit(f'{name}: anchor not unique: {old[:70]!r}')
    return t.replace(old, new)


# ---- LocTrack ----
t, nl = load('_sls_loctrackcentral.psc')
if '_SLS_TownLocChange' not in t:
    t = rep(t, '\t\tCurfew.UpdateCurfewVariables()' + nl, '', 'loctrack')
    t = rep(t, '\t\tTownCheck.PlayerLocationChange(PlayerCurrentLocIndex, akNewLoc)' + nl,
            '\t\tSendTownLocChange(PlayerCurrentLocIndex, akNewLoc) ; 3.0.2: TownCheck reacts on its own thread' + nl, 'loctrack')
    t = rep(t, '\tCurfew.IsViolatingCurfew()' + nl + '\t' + nl,
            '\t; 3.0.2: Curfew updates its location variables and checks the violation on its own thread. A direct call'
            + nl + '\t; held this script while Curfew, busy in its own update, waited to read this script.' + nl
            + '\tSendModEvent("_SLS_CurfewLocChange")' + nl + '\t' + nl, 'loctrack')
    t = rep(t, '\t\tCurfew.CheckCurfewState()' + nl + '\t\tApi.SendSlavetownEvent(PlayerIsInSlavetown)' + nl,
            '\t\tApi.SendSlavetownEvent(PlayerIsInSlavetown) ; Curfew runs CheckCurfewState on this event (3.0.2: no direct call too)' + nl,
            'loctrack')
    t = rep(t, 'Function TrackingMarkerCellAttach(ObjectReference Marker)' + nl,
            'Function SendTownLocChange(Int LocInt, Location akNewLoc)' + nl
            + '\tInt Handle = ModEvent.Create("_SLS_TownLocChange")' + nl
            + '\tIf Handle' + nl + '\t\tModEvent.PushInt(Handle, LocInt)' + nl
            + '\t\tModEvent.PushForm(Handle, akNewLoc)' + nl + '\t\tModEvent.Send(Handle)' + nl
            + '\tEndIf' + nl + 'EndFunction' + nl + nl
            + 'Function TrackingMarkerCellAttach(ObjectReference Marker)' + nl, 'loctrack')
    save('_sls_loctrackcentral.psc', t)
    print('loctrack patched')

# ---- TownCheck ----
t, nl = load('_sls_lictowncheck.psc')
if '_SLS_TownLocChange' not in t:
    t = rep(t, 'Scriptname _SLS_LicTownCheck extends Quest' + nl,
            'Scriptname _SLS_LicTownCheck extends Quest' + nl + nl
            + '; 3.0.2: town changes arrive as the mod event _SLS_TownLocChange from _SLS_LocTrackCentral instead of a direct'
            + nl + '; call (which held LocTrack through this script\'s 2 s wait). Registered here on a new game and by'
            + nl + '; SLS_Main on every load (registrations made before 3.0.2 do not exist).' + nl
            + 'Event OnInit()' + nl + '\tRegisterForLocEvents()' + nl + 'EndEvent' + nl + nl
            + 'Function RegisterForLocEvents()' + nl
            + '\tRegisterForModEvent("_SLS_TownLocChange", "On_SLS_TownLocChange")' + nl + 'EndFunction' + nl + nl
            + 'Event On_SLS_TownLocChange(Int LocInt, Form akNewLoc)' + nl
            + '\tPlayerLocationChange(LocInt, akNewLoc as Location)' + nl + 'EndEvent' + nl, 'towncheck')
    save('_sls_lictowncheck.psc', t)
    print('towncheck patched')

# ---- Curfew ----
t, nl = load('_sls_curfew.psc')
if '_SLS_CurfewLocChange' not in t:
    t = rep(t, '\tRegisterForModEvent("_SLS_PlayerIsInSlavetown", "On_SLS_PlayerIsInSlavetown")' + nl
            + '\tRegisterForModEvent("PCSubFree", "_On_SD_PCSubFree")' + nl,
            '\tRegisterForModEvent("_SLS_PlayerIsInSlavetown", "On_SLS_PlayerIsInSlavetown")' + nl
            + '\tRegisterForModEvent("_SLS_CurfewLocChange", "On_SLS_CurfewLocChange")' + nl
            + '\tLocEventRegistered = true' + nl
            + '\tRegisterForModEvent("PCSubFree", "_On_SD_PCSubFree")' + nl, 'curfew')
    t = rep(t, 'Event On_SLS_PlayerIsInSlavetown(string eventName, string strArg, float numArg, Form sender)' + nl,
            '; 3.0.2: sent by _SLS_LocTrackCentral on every location change (it no longer calls this script directly)' + nl
            + 'Event On_SLS_CurfewLocChange(string eventName, string strArg, float numArg, Form sender)' + nl
            + '\tUpdateCurfewVariables()' + nl + '\tIsViolatingCurfew()' + nl + 'EndEvent' + nl + nl
            + '; saves from before 3.0.2 never registered the event: the DLL calls IsViolatingCurfew every 2 s, so register there'
            + nl + 'Function EnsureLocEvent()' + nl + '\tIf !LocEventRegistered' + nl
            + '\t\tRegisterForModEvent("_SLS_CurfewLocChange", "On_SLS_CurfewLocChange")' + nl
            + '\t\tLocEventRegistered = true' + nl + '\tEndIf' + nl + 'EndFunction' + nl + nl
            + '; 3.0.2 (I5): the DLL owns the gate decision; drive the doors from here only without it' + nl
            + 'Function RecheckGates()' + nl + '\tIf !_SLS_IntSlsfw.GatesChanged("curfew")' + nl
            + '\t\tTollUtil.RecheckGateConditions()' + nl + '\tEndIf' + nl + 'EndFunction' + nl + nl
            + 'Event On_SLS_PlayerIsInSlavetown(string eventName, string strArg, float numArg, Form sender)' + nl, 'curfew')
    n = t.count('\t\t\tTollUtil.RecheckGateConditions()' + nl)
    if n != 4:
        sys.exit(f'curfew: expected 4 gate rechecks, found {n}')
    t = t.replace('\t\t\tTollUtil.RecheckGateConditions()' + nl, '\t\t\tRecheckGates()' + nl)
    # both IsViolatingCurfew bodies (empty state and Active) start by making sure the event is registered
    for head in ['State Active' + nl + '\tFunction IsViolatingCurfew()' + nl, nl + 'Function IsViolatingCurfew()' + nl]:
        indent = '\t\t' if head.startswith('State') else '\t'
        t = rep(t, head, head + indent + 'EnsureLocEvent()' + nl, 'curfew')
    t = t.rstrip(nl) + nl + nl + 'Bool LocEventRegistered = false' + nl
    save('_sls_curfew.psc', t)
    print('curfew patched')
