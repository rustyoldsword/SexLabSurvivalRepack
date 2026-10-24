ScriptName _sls_tolldodgehunt extends Quest Conditional

bool IsShuttingDown = false
float TollDodgeHuntFreq = 1.5
bool IsUpdateRunning = false
int MaxGuards = 6

actor Property PlayerRef Auto

bool Property SawPlayerChangeCell = false Auto Hidden Conditional

objectreference Property _SLS_TollDodgeLastKnownPos Auto

sls_mcm Property Menu Auto

_sls_tolldodge Property TollDodge Auto

referencealias Property ObserveAlias Auto

int Property DetectionCount = 0 Auto Hidden Conditional

Quest Property _SLS_TollDodgeGuardSearch Auto

int Property HunterSlotUsage = 0 Auto Hidden

int Property DetectionAtZeroCount = 0 Auto Hidden

Event OnInit()
    if IsRunning()
        DoUpdate()
    endif
    RegisterForMenu("Journal Menu")
    RefreshSettings()
EndEvent

Event OnUpdate()
    DoUpdate()
EndEvent

Event OnMenuClose(string MenuName)
    RefreshSettings()
EndEvent

Function Shutdown()
    IsShuttingDown = true
    while IsUpdateRunning
        utility.Wait(2.0)
    endwhile
    Stop()
EndFunction

Function RefreshSettings()
    TollDodgeHuntFreq = Menu.TollDodgeHuntFreq
    MaxGuards = Menu.TollDodgeMaxGuards
EndFunction

Function DoUpdate()
    if !IsShuttingDown
        IsUpdateRunning = true
        GetIsPlayerSpotted()
        GetDetectionCountHighest()
        TollDodge.UpdateHunterPackage()
        RegisterForSingleUpdate(TollDodgeHuntFreq)
        IsUpdateRunning = false
    endif
EndFunction

Function GetDetectionCountHighest()
    int i = GetNumAliases()
    int HighestCount = 0
    while i > 0
        i = i - 1
        if (GetNthAlias(i) as referencealias).GetReference()
            int HunterDetection = (GetNthAlias(i) as _sls_dodgehunthunteralias).DetectionCount
            if HunterDetection > HighestCount
                DetectionCount = HunterDetection
            endif
        endif
    endwhile
EndFunction

Function AssignHunterSlot(objectreference Hunter)
    if HunterSlotUsage < MaxGuards
        int i = GetNumAliases()
        if HunterSlotUsage < i
            int j = 0
            while j < i
                referencealias CurAlias = (GetNthAlias(j) as referencealias)
                if CurAlias.GetReference() == None
                    if IsRunning()
                        HunterSlotUsage = HunterSlotUsage + 1
                        CurAlias.ForceRefTo(Hunter)
                        (CurAlias as _sls_dodgehunthunteralias).SetupHunter()
                    endif
                    return
                endif
                j = j + 1
            endwhile
        endif
    endif
EndFunction

Function GetIsPlayerSpotted()
    ; SLSFW: the DLL picks the guards the search quest would fill (its alias conditions, closest first) and keeps the
    ; ones that detect the player, so the quest is no longer restarted on every update
    if SLSFW.IsReady()
        actor[] Spotters = SLSFW.FindDetectingGuards(_SLS_TollDodgeGuardSearch)
        int n = 0
        while n < Spotters.Length
            if Spotters[n]
                AssignHunterSlot(Spotters[n])
            endif
            n += 1
        endwhile
        return
    endif
    _SLS_TollDodgeGuardSearch.Stop()
    _SLS_TollDodgeGuardSearch.Start()
    int i = 0
    int AliasCount = _SLS_TollDodgeGuardSearch.GetNumAliases()
    while i < AliasCount
        actor Hunter = ((_SLS_TollDodgeGuardSearch.GetNthAlias(i) as referencealias).GetReference() as actor)
        if Hunter && PlayerRef.IsDetectedBy(Hunter)
            AssignHunterSlot(Hunter)
        endif
        i = i + 1
    endwhile
EndFunction

