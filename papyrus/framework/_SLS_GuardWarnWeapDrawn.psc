ScriptName _sls_guardwarnweapdrawn extends Quest

bool IsInit = true

globalvariable Property _SLS_GuardWarnDoApproach Auto

faction Property _SLS_GuardBehaviourWarningFact Auto

globalvariable Property _SLS_GuardWarnTypeAndCooldown Auto

Quest Property _SLS_GuardWarnWeapDrawnDetectionQuest Auto

sls_utility Property Util Auto

globalvariable Property _SLS_PlayerIsAIDriven Auto

actor Property PlayerRef Auto

Event OnInit()
    if IsRunning()
        RegisterForSingleUpdate(0.1)
    endif
EndEvent

Event OnUpdate()
    if IsInit
        IsInit = false
        DoInit()
    elseif !CheckIsDetected()
        RegForUpdate()
    endif
EndEvent

Function DoInit()
    _SLS_GuardWarnDoApproach.SetValueInt(0)
    _SLS_GuardWarnWeapDrawnDetectionQuest.Stop()
    if !CheckIsDetected()
        RegForUpdate()
    endif
EndFunction

Function RegForUpdate()
    if PlayerRef.IsInCombat()
        RegisterForSingleUpdate(30.0)
    else
        RegisterForSingleUpdate(3.0)
    endif
EndFunction

bool Function CheckIsDetected()
    if _SLS_GuardWarnTypeAndCooldown.GetValueInt() == 0
        _SLS_PlayerIsAIDriven.SetValueInt((PlayerRef.GetCurrentPackage() != None) as int)
        ; SLSFW: no loaded guard passes the detection alias's conditions (it needs one that sees the player) -> not detected
        if SLSFW.IsReady() && !SLSFW.AliasHasMatch(_SLS_GuardWarnWeapDrawnDetectionQuest, 0)
            if _SLS_GuardWarnWeapDrawnDetectionQuest.IsRunning()
                _SLS_GuardWarnWeapDrawnDetectionQuest.Stop()
            endif
            return false
        endif
        _SLS_GuardWarnWeapDrawnDetectionQuest.Stop()
        _SLS_GuardWarnWeapDrawnDetectionQuest.Start()
        actor Guard = ((_SLS_GuardWarnWeapDrawnDetectionQuest.GetNthAlias(0) as referencealias).GetReference() as actor)
        if Guard
            _SLS_GuardWarnTypeAndCooldown.SetValueInt(6)
            if Guard.IsInFaction(_SLS_GuardBehaviourWarningFact)
                _SLS_GuardWarnWeapDrawnDetectionQuest.Stop()
                Util.SendBeginGuardWarnPunishEvent(_SLS_GuardWarnWeapDrawnDetectionQuest, Guard)
            endif
            _SLS_GuardWarnDoApproach.SetValueInt(1)
            Guard.EvaluatePackage()
            return true
        else
            return false
        endif
    else
        return false
    endif
EndFunction

