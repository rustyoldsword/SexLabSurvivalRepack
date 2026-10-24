scriptname SexLabFramework extends Quest
string property ModName auto
int function GetVersion()
	Return 0
Endfunction
string function GetStringVer()
	Return ""
Endfunction
bool property Enabled hidden
bool function get()
	Return False
Endfunction
endProperty
bool property IsRunning hidden
bool function get()
	Return False
Endfunction
endProperty
int property ActiveAnimations hidden
int function get()
	Return 0
Endfunction
endProperty
bool property AllowCreatures hidden
bool function get()
	Return False
Endfunction
endProperty
bool property CreatureGenders hidden
bool function get()
	Return False
Endfunction
endProperty
sslThreadModel function NewThread(float TimeOut = 30.0)
	Return None
Endfunction
int function StartSex(Actor[] Positions, sslBaseAnimation[] Anims, Actor Victim = none, ObjectReference CenterOn = none, bool AllowBed = true, string Hook = "")
	Return 0
Endfunction
sslThreadController function QuickStart(Actor Actor1, Actor Actor2 = none, Actor Actor3 = none, Actor Actor4 = none, Actor Actor5 = none, Actor Victim = none, string Hook = "", string AnimationTags = "")
	Return None
Endfunction
int function GetGender(Actor ActorRef)
	Return 0
Endfunction
function TreatAsMale(Actor ActorRef)
Endfunction
function TreatAsFemale(Actor ActorRef)
Endfunction
function TreatAsGender(Actor ActorRef, bool AsFemale)
Endfunction
function ClearForcedGender(Actor ActorRef)
Endfunction
int[] function GenderCount(Actor[] Positions)
	Return None
Endfunction
int[] function TransGenderCount(Actor[] Positions)
	Return None
Endfunction
int function MaleCount(Actor[] Positions)
	Return 0
Endfunction
int function FemaleCount(Actor[] Positions)
	Return 0
Endfunction
int function CreatureCount(Actor[] Positions)
	Return 0
Endfunction
int function TransMaleCount(Actor[] Positions)
	Return 0
Endfunction
int function TransFemaleCount(Actor[] Positions)
	Return 0
Endfunction
int function TransCreatureCount(Actor[] Positions)
	Return 0
Endfunction
int function ValidateActor(Actor ActorRef)
	Return 0
Endfunction
bool function IsValidActor(Actor ActorRef)
	Return False
Endfunction
bool function IsActorActive(Actor ActorRef)
	Return False
Endfunction
function ForbidActor(Actor ActorRef)
Endfunction
function AllowActor(Actor ActorRef)
Endfunction
bool function IsForbidden(Actor ActorRef)
	Return False
Endfunction
Actor function FindAvailableActor(ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none)
	Return None
Endfunction
Actor function FindAvailableActorByFaction(Faction FactionRef, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, bool HasFaction = True)
	Return None
Endfunction
Actor function FindAvailableActorWornForm(int slotMask, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, bool AvoidNoStripKeyword = True, bool HasWornForm = True)
	Return None
Endfunction
Actor function FindAvailableCreature(string RaceKey, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = 2, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none)
	Return None
Endfunction
Actor function FindAvailableCreatureByFaction(string RaceKey, Faction FactionRef, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, bool HasFaction = True)
	Return None
Endfunction
Actor function FindAvailableCreatureWornForm(string RaceKey, int slotMask, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, bool AvoidNoStripKeyword = True, bool HasWornForm = True)
	Return None
Endfunction
Actor[] function FindAvailablePartners(Actor[] Positions, int TotalActors, int Males = -1, int Females = -1, float Radius = 10000.0)
	Return None
Endfunction
Actor[] function SortActors(Actor[] Positions, bool FemaleFirst = true)
	Return None
Endfunction
Actor[] function SortActorsByAnimation(Actor[] Positions, sslBaseAnimation Animation = none)
	Return None
Endfunction
Actor[] function SortCreatures(Actor[] Positions, sslBaseAnimation Animation = none)
	Return None
Endfunction
function AddCum(Actor ActorRef, bool Vaginal = true, bool Oral = true, bool Anal = true)
Endfunction
function ClearCum(Actor ActorRef)
Endfunction
int function CountCum(Actor ActorRef, bool Vaginal = true, bool Oral = true, bool Anal = true)
	Return 0
Endfunction
int function CountCumVaginal(Actor ActorRef)
	Return 0
Endfunction
int function CountCumOral(Actor ActorRef)
	Return 0
Endfunction
int function CountCumAnal(Actor ActorRef)
	Return 0
Endfunction
Form[] function StripActor(Actor ActorRef, Actor VictimRef = none, bool DoAnimate = true, bool LeadIn = false)
	Return None
Endfunction
Form[] function StripSlots(Actor ActorRef, bool[] Strip, bool DoAnimate = false, bool AllowNudesuit = true)
	Return None
Endfunction
function UnstripActor(Actor ActorRef, Form[] Stripped, bool IsVictim = false)
Endfunction
bool function IsStrippable(Form ItemRef)
	Return False
Endfunction
Form function StripSlot(Actor ActorRef, int SlotMask)
	Return None
Endfunction
Form function WornStrapon(Actor ActorRef)
	Return None
Endfunction
bool function HasStrapon(Actor ActorRef)
	Return False
Endfunction
Form function PickStrapon(Actor ActorRef)
	Return None
Endfunction
Form function EquipStrapon(Actor ActorRef)
	Return None
Endfunction
function UnequipStrapon(Actor ActorRef)
Endfunction
Armor function LoadStrapon(string esp, int id)
	Return None
Endfunction
bool function CheckBardAudience(Actor ActorRef, bool RemoveFromAudience = true)
	Return False
Endfunction
ObjectReference function FindBed(ObjectReference CenterRef, float Radius = 1000.0, bool IgnoreUsed = true, ObjectReference IgnoreRef1 = none, ObjectReference IgnoreRef2 = none)
	Return None
Endfunction
bool function IsBedRoll(ObjectReference BedRef)
	Return False
Endfunction
bool function IsDoubleBed(ObjectReference BedRef)
	Return False
Endfunction
bool function IsSingleBed(ObjectReference BedRef)
	Return False
Endfunction
bool function IsBedAvailable(ObjectReference BedRef)
	Return False
Endfunction
bool function AddCustomBed(Form BaseBed, int BedType = 0)
	Return False
Endfunction
bool function SetCustomBedOffset(Form BaseBed, float Forward = 30.0, float Sideward = 0.0, float Upward = 37.0, float Rotation = 0.0)
	Return False
Endfunction
bool function ClearCustomBedOffset(Form BaseBed)
	Return False
Endfunction
float[] function GetBedOffsets(Form BaseBed)
	Return None
Endfunction
sslThreadController function GetController(int tid)
	Return None
Endfunction
int function FindActorController(Actor ActorRef)
	Return 0
Endfunction
int function FindPlayerController()
	Return 0
Endfunction
sslThreadController function GetActorController(Actor ActorRef)
	Return None
Endfunction
sslThreadController function GetPlayerController()
	Return None
Endfunction
function TrackActor(Actor ActorRef, string Callback)
Endfunction
function UntrackActor(Actor ActorRef, string Callback)
Endfunction
function TrackFaction(Faction FactionRef, string Callback)
Endfunction
function UntrackFaction(Faction FactionRef, string Callback)
Endfunction
function SendTrackedEvent(Actor ActorRef, string Hook, int id = -1)
Endfunction
bool function IsActorTracked(Actor ActorRef)
	Return False
Endfunction
sslBaseAnimation[] function GetAnimationsByTags(int ActorCount, string Tags, string TagSuppress = "", bool RequireAll = true)
	Return None
Endfunction
sslBaseAnimation[] function GetAnimationsByType(int ActorCount, int Males = -1, int Females = -1, int StageCount = -1, bool Aggressive = false, bool Sexual = true)
	Return None
Endfunction
sslBaseAnimation[] function PickAnimationsByActors(Actor[] Positions, int Limit = 64, bool Aggressive = false)
	Return None
Endfunction
sslBaseAnimation[] function GetAnimationsByDefault(int Males, int Females, bool IsAggressive = false, bool UsingBed = false, bool RestrictAggressive = true)
	Return None
Endfunction
sslBaseAnimation[] function GetAnimationsByDefaultTags(int Males, int Females, bool IsAggressive = false, bool UsingBed = false, bool RestrictAggressive = true, string Tags, string TagsSuppressed = "", bool RequireAll = true)
	Return None
Endfunction
sslBaseAnimation function GetAnimationByName(string FindName)
	Return None
Endfunction
sslBaseAnimation function GetAnimationByRegistry(string Registry)
	Return None
Endfunction
int function FindAnimationByName(string FindName)
	Return 0
Endfunction
int function GetAnimationCount(bool IgnoreDisabled = true)
	Return 0
Endfunction
string function MakeAnimationGenderTag(Actor[] Positions)
	Return ""
Endfunction
string function GetGenderTag(int Females = 0, int Males = 0, int Creatures = 0)
	Return ""
Endfunction
sslBaseAnimation[] function MergeAnimationLists(sslBaseAnimation[] List1, sslBaseAnimation[] List2)
	Return None
Endfunction
sslBaseAnimation[] function RemoveTagged(sslBaseAnimation[] Anims, string Tags)
	Return None
Endfunction
int function CountTag(sslBaseAnimation[] Anims, string Tags)
	Return 0
Endfunction
int function CountTagUsage(string Tags, bool IgnoreDisabled = true)
	Return 0
Endfunction
int function CountCreatureTagUsage(string Tags, bool IgnoreDisabled = true)
	Return 0
Endfunction
string[] function GetAllAnimationTags(int ActorCount = -1, bool IgnoreDisabled = true)
	Return None
Endfunction
string[] function GetAllAnimationTagsInArray(sslBaseAnimation[] List)
	Return None
Endfunction
sslBaseAnimation[] function GetCreatureAnimationsByRace(int ActorCount, Race RaceRef)
	Return None
Endfunction
sslBaseAnimation[] function GetCreatureAnimationsByRaceTags(int ActorCount, Race RaceRef, string Tags, string TagSuppress = "", bool RequireAll = true)
	Return None
Endfunction
sslBaseAnimation[] function GetCreatureAnimationsByRaceGenders(int ActorCount, Race RaceRef, int MaleCreatures = 0, int FemaleCreatures = 0, bool ForceUse = false)
	Return None
Endfunction
sslBaseAnimation[] function GetCreatureAnimationsByRaceGendersTags(int ActorCount, Race RaceRef, int MaleCreatures = 0, int FemaleCreatures = 0, string Tags, string TagSuppress = "", bool RequireAll = true)
	Return None
Endfunction
sslBaseAnimation[] function GetCreatureAnimationsByRaceKey(int ActorCount, string RaceKey)
	Return None
Endfunction
sslBaseAnimation[] function GetCreatureAnimationsByRaceKeyTags(int ActorCount, string RaceKey, string Tags, string TagSuppress = "", bool RequireAll = true)
	Return None
Endfunction
sslBaseAnimation[] function GetCreatureAnimationsByActors(int ActorCount, Actor[] Positions)
	Return None
Endfunction
sslBaseAnimation[] function GetCreatureAnimationsByActorsTags(int ActorCount, Actor[] Positions, string Tags, string TagSuppress = "", bool RequireAll = true)
	Return None
Endfunction
sslBaseAnimation function GetCreatureAnimationByName(string FindName)
	Return None
Endfunction
sslBaseAnimation function GetCreatureAnimationByRegistry(string Registry)
	Return None
Endfunction
bool function HasCreatureRaceAnimation(Race CreatureRace, int ActorCount = -1, int Gender = -1)
	Return False
Endfunction
bool function HasCreatureRaceKeyAnimation(string RaceKey, int ActorCount = -1, int Gender = -1)
	Return False
Endfunction
bool function AllowedCreature(Race CreatureRace)
	Return False
Endfunction
bool function AllowedCreatureCombination(Race CreatureRace, Race CreatureRace2)
	Return False
Endfunction
string[] function GetAllCreatureAnimationTags(int ActorCount = -1, bool IgnoreDisabled = true)
	Return None
Endfunction
string[] function GetAllBothAnimationTags(int ActorCount = -1, bool IgnoreDisabled = true)
	Return None
Endfunction
sslBaseVoice function PickVoice(Actor ActorRef)
	Return None
Endfunction
sslBaseVoice function GetVoice(Actor ActorRef)
	Return None
Endfunction
function SaveVoice(Actor ActorRef, sslBaseVoice Saving)
Endfunction
function ForgetVoice(Actor ActorRef)
Endfunction
sslBaseVoice function GetSavedVoice(Actor ActorRef)
	Return None
Endfunction
bool function HasCustomVoice(Actor ActorRef)
	Return False
Endfunction
sslBaseVoice function GetVoiceByGender(int Gender)
	Return None
Endfunction
sslBaseVoice[] function GetVoicesByGender(int Gender)
	Return None
Endfunction
sslBaseVoice function GetVoiceByName(string FindName)
	Return None
Endfunction
int function FindVoiceByName(string FindName)
	Return 0
Endfunction
sslBaseVoice function GetVoiceBySlot(int slot)
	Return None
Endfunction
sslBaseVoice function GetVoiceByTags(string Tags, string TagSuppress = "", bool RequireAll = true)
	Return None
Endfunction
sslBaseVoice[] function GetVoicesByTags(string Tags, string TagSuppress = "", bool RequireAll = true)
	Return None
Endfunction
sslBaseExpression function PickExpression(Actor ActorRef, Actor VictimRef = none)
	Return None
Endfunction
sslBaseExpression function PickExpressionByStatus(Actor ActorRef, bool IsVictim = false, bool IsAggressor = false)
	Return None
Endfunction
sslBaseExpression[] function GetExpressionsByStatus(Actor ActorRef, bool IsVictim = false, bool IsAggressor = false)
	Return None
Endfunction
sslBaseExpression function PickExpressionsByTag(Actor ActorRef, string Tag)
	Return None
Endfunction
sslBaseExpression[] function GetExpressionsByTag(Actor ActorRef, string Tag)
	Return None
Endfunction
sslBaseExpression function GetExpressionByName(string findName)
	Return None
Endfunction
int function FindExpressionByName(string findName)
	Return 0
Endfunction
sslBaseExpression function GetExpressionBySlot(int slot)
	Return None
Endfunction
function OpenMouth(Actor ActorRef)
Endfunction
function CloseMouth(Actor ActorRef)
Endfunction
bool function IsMouthOpen(Actor ActorRef)
	Return False
Endfunction
float[] function GetCurrentMFG(Actor ActorRef)
	Return None
Endfunction
function ClearMFG(Actor ActorRef)
Endfunction
function ClearPhoneme(Actor ActorRef)
Endfunction
function ClearModifier(Actor ActorRef)
Endfunction
function ApplyPresetFloats(Actor ActorRef, float[] Preset)
Endfunction
int function GetEnjoyment(int tid, Actor ActorRef)
	Return 0
Endfunction
bool function IsVictim(int tid, Actor ActorRef)
	Return False
Endfunction
bool function IsAggressor(int tid, Actor ActorRef)
	Return False
Endfunction
bool function IsUsingStrapon(int tid, Actor ActorRef)
	Return False
Endfunction
bool function PregnancyRisk(int tid, Actor ActorRef, bool AllowFemaleCum = false, bool AllowCreatureCum = false)
	Return False
Endfunction
int function RegisterStat(string Name, string Value, string Prepend = "", string Append = "")
	Return 0
Endfunction
function Alter(string Name, string NewName = "", string Value = "", string Prepend = "", string Append = "")
Endfunction
int function FindStat(string Name)
	Return 0
Endfunction
string function GetActorStat(Actor ActorRef, string Name)
	Return ""
Endfunction
int function GetActorStatInt(Actor ActorRef, string Name)
	Return 0
Endfunction
float function GetActorStatFloat(Actor ActorRef, string Name)
	Return 0.0
Endfunction
string function SetActorStat(Actor ActorRef, string Name, string Value)
	Return ""
Endfunction
int function ActorAdjustBy(Actor ActorRef, string Name, int AdjustBy)
	Return 0
Endfunction
string function GetActorStatFull(Actor ActorRef, string Name)
	Return ""
Endfunction
string function GetStatFull(string Name)
	Return ""
Endfunction
string function GetStat(string Name)
	Return ""
Endfunction
int function GetStatInt(string Name)
	Return 0
Endfunction
float function GetStatFloat(string Name)
	Return 0.0
Endfunction
string function SetStat(string Name, string Value)
	Return ""
Endfunction
int function AdjustBy(string Name, int AdjustBy)
	Return 0
Endfunction
int function CalcSexuality(bool IsFemale, int males, int females)
	Return 0
Endfunction
int function CalcLevel(float total, float curve = 0.65)
	Return 0
Endfunction
string function ParseTime(int time)
	Return ""
Endfunction
int function PlayerSexCount(Actor ActorRef)
	Return 0
Endfunction
bool function HadPlayerSex(Actor ActorRef)
	Return False
Endfunction
Actor function MostUsedPlayerSexPartner()
	Return None
Endfunction
Actor[] function MostUsedPlayerSexPartners(int MaxActors = 5)
	Return None
Endfunction
Actor function LastSexPartner(Actor ActorRef)
	Return None
Endfunction
bool function HasHadSexTogether(Actor ActorRef1, Actor ActorRef2)
	Return False
Endfunction
Actor function LastAggressor(Actor ActorRef)
	Return None
Endfunction
bool function WasVictimOf(Actor VictimRef, Actor AggressorRef)
	Return False
Endfunction
Actor function LastVictim(Actor ActorRef)
	Return None
Endfunction
bool function WasAggressorTo(Actor AggressorRef, Actor VictimRef)
	Return False
Endfunction
float function AdjustPurity(Actor ActorRef, float amount)
	Return 0.0
Endfunction
function SetSexuality(Actor ActorRef, int amount)
Endfunction
function SetSexualityStraight(Actor ActorRef)
Endfunction
function SetSexualityBisexual(Actor ActorRef)
Endfunction
function SetSexualityGay(Actor ActorRef)
Endfunction
int function GetSexuality(Actor ActorRef)
	Return 0
Endfunction
string function GetSexualityTitle(Actor ActorRef)
	Return ""
Endfunction
string function GetSkillTitle(Actor ActorRef, string Skill)
	Return ""
Endfunction
int function GetSkill(Actor ActorRef, string Skill)
	Return 0
Endfunction
int function GetSkillLevel(Actor ActorRef, string Skill)
	Return 0
Endfunction
float function GetPurity(Actor ActorRef)
	Return 0.0
Endfunction
int function GetPurityLevel(Actor ActorRef)
	Return 0
Endfunction
string function GetPurityTitle(Actor ActorRef)
	Return ""
Endfunction
bool function IsPure(Actor ActorRef)
	Return False
Endfunction
bool function IsLewd(Actor ActorRef)
	Return False
Endfunction
bool function IsStraight(Actor ActorRef)
	Return False
Endfunction
bool function IsBisexual(Actor ActorRef)
	Return False
Endfunction
bool function IsGay(Actor ActorRef)
	Return False
Endfunction
int function SexCount(Actor ActorRef)
	Return 0
Endfunction
bool function HadSex(Actor ActorRef)
	Return False
Endfunction
float function LastSexGameTime(Actor ActorRef)
	Return 0.0
Endfunction
float function DaysSinceLastSex(Actor ActorRef)
	Return 0.0
Endfunction
float function HoursSinceLastSex(Actor ActorRef)
	Return 0.0
Endfunction
float function MinutesSinceLastSex(Actor ActorRef)
	Return 0.0
Endfunction
float function SecondsSinceLastSex(Actor ActorRef)
	Return 0.0
Endfunction
string function LastSexTimerString(Actor ActorRef)
	Return ""
Endfunction
float function LastSexRealTime(Actor ActorRef)
	Return 0.0
Endfunction
float function DaysSinceLastSexRealTime(Actor ActorRef)
	Return 0.0
Endfunction
float function HoursSinceLastSexRealTime(Actor ActorRef)
	Return 0.0
Endfunction
float function MinutesSinceLastSexRealTime(Actor ActorRef)
	Return 0.0
Endfunction
float function SecondsSinceLastSexRealTime(Actor ActorRef)
	Return 0.0
Endfunction
string function LastSexTimerStringRealTime(Actor ActorRef)
	Return ""
Endfunction
float function AdjustPlayerPurity(float amount)
	Return 0.0
Endfunction
int function GetPlayerPurityLevel()
	Return 0
Endfunction
string function GetPlayerPurityTitle()
	Return ""
Endfunction
string function GetPlayerSexualityTitle()
	Return ""
Endfunction
int function GetPlayerSkillLevel(string Skill)
	Return 0
Endfunction
string function GetPlayerSkillTitle(string Skill)
	Return ""
Endfunction
sslBaseAnimation function RegisterAnimation(string Registrar, Form CallbackForm = none, ReferenceAlias CallbackAlias = none)
	Return None
Endfunction
sslBaseAnimation function RegisterCreatureAnimation(string Registrar, Form CallbackForm = none, ReferenceAlias CallbackAlias = none)
	Return None
Endfunction
sslBaseVoice function RegisterVoice(string Registrar, Form CallbackForm = none, ReferenceAlias CallbackAlias = none)
	Return None
Endfunction
sslBaseExpression function RegisterExpression(string Registrar, Form CallbackForm = none, ReferenceAlias CallbackAlias = none)
	Return None
Endfunction
sslBaseAnimation function NewAnimationObject(string Token, Form Owner)
	Return None
Endfunction
sslBaseVoice function NewVoiceObject(string Token, Form Owner)
	Return None
Endfunction
sslBaseExpression function NewExpressionObject(string Token, Form Owner)
	Return None
Endfunction
sslBaseAnimation function GetSetAnimationObject(string Token, string Callback, Form Owner)
	Return None
Endfunction
sslBaseVoice function GetSetVoiceObject(string Token, string Callback, Form Owner)
	Return None
Endfunction
sslBaseExpression function GetSetExpressionObject(string Token, string Callback, Form Owner)
	Return None
Endfunction
sslBaseAnimation function NewAnimationObjectCopy(string Token, sslBaseAnimation CopyFrom, Form Owner)
	Return None
Endfunction
sslBaseVoice function NewVoiceObjectCopy(string Token, sslBaseVoice CopyFrom, Form Owner)
	Return None
Endfunction
sslBaseExpression function NewExpressionObjectCopy(string Token, sslBaseExpression CopyFrom, Form Owner)
	Return None
Endfunction
sslBaseAnimation function GetAnimationObject(string Token)
	Return None
Endfunction
sslBaseVoice function GetVoiceObject(string Token)
	Return None
Endfunction
sslBaseExpression function GetExpressionObject(string Token)
	Return None
Endfunction
sslBaseAnimation[] function GetOwnerAnimations(Form Owner)
	Return None
Endfunction
sslBaseVoice[] function GetOwnerVoices(Form Owner)
	Return None
Endfunction
sslBaseExpression[] function GetOwnerExpressions(Form Owner)
	Return None
Endfunction
bool function HasAnimationObject(string Token)
	Return False
Endfunction
bool function HasVoiceObject(string Token)
	Return False
Endfunction
bool function HasExpressionObject(string Token)
	Return False
Endfunction
bool function ReleaseAnimationObject(string Token)
	Return False
Endfunction
bool function ReleaseVoiceObject(string Token)
	Return False
Endfunction
bool function ReleaseExpressionObject(string Token)
	Return False
Endfunction
int function ReleaseOwnerAnimations(Form Owner)
	Return 0
Endfunction
int function ReleaseOwnerVoices(Form Owner)
	Return 0
Endfunction
int function ReleaseOwnerExpressions(Form Owner)
	Return 0
Endfunction
sslBaseAnimation function MakeAnimationRegistered(string Token)
	Return None
Endfunction
sslBaseVoice function MakeVoiceRegistered(string Token)
	Return None
Endfunction
sslBaseExpression function MakeExpressionRegistered(string Token)
	Return None
Endfunction
bool function RemoveRegisteredAnimation(string Registrar)
	Return False
Endfunction
bool function RemoveRegisteredCreatureAnimation(string Registrar)
	Return False
Endfunction
bool function RemoveRegisteredVoice(string Registrar)
	Return False
Endfunction
bool function RemoveRegisteredExpression(string Registrar)
	Return False
Endfunction
Actor[] function MakeActorArray(Actor Actor1 = none, Actor Actor2 = none, Actor Actor3 = none, Actor Actor4 = none, Actor Actor5 = none)
	Return None
Endfunction
sslThreadController function HookController(string argString)
	Return None
Endfunction
sslBaseAnimation function HookAnimation(string argString)
	Return None
Endfunction
int function HookStage(string argString)
	Return 0
Endfunction
Actor function HookVictim(string argString)
	Return None
Endfunction
Actor[] function HookActors(string argString)
	Return None
Endfunction
float function HookTime(string argString)
	Return 0.0
Endfunction
bool function HasCreatureAnimation(Race CreatureRace, int Gender = -1)
	Return False
Endfunction
sslBaseAnimation[] function GetAnimationsByTag(int ActorCount, string Tag1, string Tag2 = "", string Tag3 = "", string TagSuppress = "", bool RequireAll = true)
	Return None
Endfunction
sslBaseAnimation[] function GetCreatureAnimationsByTags(int ActorCount, string Tags, string TagSuppress = "", bool RequireAll = true)
	Return None
Endfunction
sslBaseVoice function GetVoiceByTag(string Tag1, string Tag2 = "", string TagSuppress = "", bool RequireAll = true)
	Return None
Endfunction
function ApplyCum(Actor ActorRef, int CumID)
Endfunction
form function StripWeapon(Actor ActorRef, bool RightHand = true)
	Return None
Endfunction
sslBaseAnimation[] property Animations hidden
sslBaseAnimation[] function get()
	Return None
Endfunction
endProperty
sslBaseAnimation[] property CreatureAnimations hidden
sslBaseAnimation[] function get()
	Return None
Endfunction
endProperty
sslBaseVoice[] property Voices hidden
sslBaseVoice[] function get()
	Return None
Endfunction
endProperty
sslBaseExpression[] property Expressions hidden
sslBaseExpression[] function get()
	Return None
Endfunction
endProperty
sslBaseExpression function RandomExpressionByTag(string Tag)
	Return None
Endfunction
function ApplyPreset(Actor ActorRef, int[] Preset)
Endfunction
sslThreadController[] property Threads hidden
sslThreadController[] function get()
	Return None
Endfunction
endProperty
bool function IsImpure(Actor ActorRef)
	Return False
Endfunction
int function GetPlayerStatLevel(string Skill)
	Return 0
Endfunction
sslSystemConfig property Config auto hidden
Faction property AnimatingFaction auto hidden
Actor property PlayerRef auto hidden
sslActorLibrary property ActorLib auto hidden
sslThreadLibrary property ThreadLib auto hidden
sslActorStats property Stats auto hidden
sslThreadSlots property ThreadSlots auto hidden
sslAnimationSlots property AnimSlots auto hidden
sslCreatureAnimationSlots property CreatureSlots auto hidden
sslVoiceSlots property VoiceSlots auto hidden
sslExpressionSlots property ExpressionSlots auto hidden
sslObjectFactory property Factory auto hidden
SexLabFramework SexLab
bool IsExtension
function Setup()
Endfunction
event OnInit()
Endevent
function Log(string Log, string Type = "NOTICE")
Endfunction
