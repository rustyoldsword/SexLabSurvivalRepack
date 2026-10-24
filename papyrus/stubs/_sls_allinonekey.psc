Scriptname _SLS_AllInOneKey extends Quest
Event OnInit()
EndEvent
Function SetKey(Int KeyCode)
EndFunction
Function SetStatusKey(Int KeyCode)
EndFunction
Event OnKeyDown(Int KeyCode)
EndEvent
Event OnMenuClose(String MenuName)
EndEvent
Function LoadGameMaintenance()
EndFunction
Actor Function GetMenuTargetActor()
	Return None
EndFunction
Function MainMenu()
EndFunction
Int Function ShowMainMenu()
	Return 0
EndFunction
Function SelfMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowSelfMenu()
	Return 0
EndFunction
Function EmoteMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowEmoteMenu()
	Return 0
EndFunction
Function AhegaoMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowAhegaoMenu()
	Return 0
EndFunction
Function ChangeStanceMenu(Bool IsShortcut = false)
EndFunction
Function BendOverMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowBendOverMenu()
	Return 0
EndFunction
Int Function ShowChangeStanceMenu()
	Return 0
EndFunction
Function ChangeAnimationSetMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowChangeAnimationSetMenu(Bool IsShortcut = false)
	Return 0
EndFunction
Function ToggleKneel()
EndFunction
Event OnAnimationEnd(int tid, bool HasPlayer)
EndEvent
Function PlayWithMyselfMenu(Bool IsShortcut = false)
EndFunction
Function Masturbate()
EndFunction
sslBaseAnimation Function ShowMasturbationList()
	Return None
EndFunction
Int Function ShowPlayWithMyselfMenu()
	Return 0
EndFunction
Function DanceRootMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowDanceRootMenu()
	Return 0
EndFunction
Function DanceMenu(Int ModSelect)
EndFunction
Int Function ShowDanceMenu(Int ModSelect)
	Return 0
EndFunction
Function TongueMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowTongueMenu()
	Return 0
EndFunction
Function TongueCleanup(Actor akActor)
EndFunction
Function ToggleCrawl()
EndFunction
Function BeginLookAt(ObjectReference akTarget = None, Bool MoveMarker = true)
EndFunction
Function ClearLookAtTarget(Int ForcePlayerIsNpcTo = -1)
EndFunction
Event OnAnimationEvent(ObjectReference aktarg, String EventName)
EndEvent
ObjectReference Function ShowLookAtMenulist()
	Return None
EndFunction
Function ToggleTongue(Int MenuSelect)
EndFunction
Function AhegaoClear(Actor akActor)
EndFunction
Function AhegaoFaceRandom(Actor akActor)
EndFunction
Function AhegaoFace(Actor akActor, String Face)
EndFunction
Function DoAhegaoExpression(Actor akActor, Int[] AhegaoValues)
EndFunction
Function ActionsMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowActionsMenu()
	Return 0
EndFunction
Function WaitMenu()
EndFunction
Int Function ShowWaitMenu()
	Return 0
EndFunction
Function CumMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowCumMenu()
	Return 0
EndFunction
Function CollectCumMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowCollectCumMenu()
	Return 0
EndFunction
Function PourCumMenu(Form CumPotion, Actor akActor, Bool IsShortcut = false)
EndFunction
Int Function ShowPourCumMenu()
	Return 0
EndFunction
Function ShowCumPotionList(Actor akActor)
EndFunction
Function MoreActionsMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowMoreActionsMenu()
	Return 0
EndFunction
Function ToggleAutoFuck()
EndFunction
Function UntieNpc(Bool IsShortcut = false)
EndFunction
Int Function ShowUntieNpcMenu()
	Return 0
EndFunction
Function ExamineDeviceMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowExamineDeviceMenu()
	Return 0
EndFunction
Function TattooNpc()
EndFunction
Function SpankNpc()
EndFunction
Function OutfitMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowOutfitMenu()
	Return 0
EndFunction
Function SaveOutfitMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowSaveOutfitMenu()
	Return 0
EndFunction
Function Undress()
EndFunction
Function Dress()
EndFunction
Function EquipOutfit(Form[] OutfitArray)
EndFunction
Form[] Function GetOutfitArray(Int OutfitNumber)
	Return None
EndFunction
Function SaveOutfit(Int OutfitNumber)
EndFunction
Function BegForCockMenu(Bool IsShortcut = false)
EndFunction
Actor Function FindBegForCockResponder()
	Return None
EndFunction
Int Function ShowBegForCockMenu()
	Return 0
EndFunction
Function SurvivalMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowSurvivalMenu()
	Return 0
EndFunction
Function WildlingMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowWildlingMenu()
	Return 0
EndFunction
Function CraftingMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowCraftingMenu()
	Return 0
EndFunction
Function SurvivalSkillsMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowSurvivalSkillsMenu()
	Return 0
EndFunction
Function SenseMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowSenseMenu()
	Return 0
EndFunction
Function SearchDistanceMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowSearchDistanceMenu()
	Return 0
EndFunction
Function BeginSearchGround(Bool IsShortcut = false)
EndFunction
Function SearchGroundMenu()
EndFunction
Int Function ShowSearchGroundMenu()
	Return 0
EndFunction
Function SleepOnGround()
EndFunction
Function DoSleepOnGround()
EndFunction
Function BatheMenu(Bool IsShortcut = false)
EndFunction
MiscObject Function ShowSoapMenu()
	Return None
EndFunction
Function IdleMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowIdleMenu()
	Return 0
EndFunction
Function IdleCombatMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowIdleCombatMenu()
	Return 0
EndFunction
Function FlyYouFools()
EndFunction
Function Taunt()
EndFunction
Function Stretch()
EndFunction
Function IdleGesturesMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowIdleGestureMenu()
	Return 0
EndFunction
Function Hug()
EndFunction
Function Applaud()
EndFunction
Function Salute()
EndFunction
Function ComeThisWay()
EndFunction
Function AttractAttention()
EndFunction
Function Wave()
EndFunction
Function StatusMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowStatusMenu()
	Return 0
EndFunction
Function MiscMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowMiscMenu()
	Return 0
EndFunction
Function AssignFavorite()
EndFunction
Int Function ShowAssignFavoriteMenu()
	Return 0
EndFunction
Bool Function GetIsTransferableTarget(ObjectReference TargetRef)
	Return False
EndFunction
Function ContainerTransferMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowContainerTransferMenu(ObjectReference TargetRef)
	Return 0
EndFunction
Function TransferToMenu(ObjectReference DestRef, Bool IsShortcut = false)
EndFunction
Int Function ShowTransferToMenu(ObjectReference DestRef)
	Return 0
EndFunction
Function TeleportFollowersMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowTeleportFollowersMenu()
	Return 0
EndFunction
Int Function TeleportToFollower()
	Return 0
EndFunction
Int Function TeleportOneFollowerToMe()
	Return 0
EndFunction
Function TeleportAllFollowersToMe()
EndFunction
Function TeleportActorToMe(Actor akActor)
EndFunction
Int Function ShowFollowersListMenu()
	Return 0
EndFunction
Function DebugMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowDebugMenu()
	Return 0
EndFunction
Function Stuck1()
EndFunction
Function Stuck2()
EndFunction
Function DroppedItemsMenu()
EndFunction
Int Function ShowDroppedItemsMenu()
	Return 0
EndFunction
Function RaceDoorFlagMenu()
EndFunction
Int Function ShowRaceDoorFlagMenu(Actor akTarget)
	Return 0
EndFunction
Int Function GetAnimActorCount()
	Return 0
EndFunction
Int Function ShowGetAnimActorCount()
	Return 0
EndFunction
Function GetAnimationsListByTags()
EndFunction
Function PrintVendorGoldEstimations()
EndFunction
String Function GetCombinedVendorListEstimation(ObjectReference Chest, String ListName, LeveledItem MaleList, LeveledItem FemaleList)
	Return ""
EndFunction
String Function GetRootVendorListEstimation(ObjectReference Chest, String ListName, LeveledItem List)
	Return ""
EndFunction
Function StolenStuffMenu(Bool IsShortcut = false)
EndFunction
Function EvictionConfiscationsMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowEvictionConfiscationsMenu()
	Return 0
EndFunction
Int Function ShowStolenStuffMenu()
	Return 0
EndFunction
Function TraumaMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowTraumaMenu()
	Return 0
EndFunction
Function IssueLicenceMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowIssueLicenceMenu()
	Return 0
EndFunction
Function IssueSingleLicence(Int Duration)
EndFunction
Int Function ShowIssueSingleLicenceMenu()
	Return 0
EndFunction
Function IssueAllLicences(Int LicDuration)
EndFunction
Function IssueLicence(Int LicType, Int LicDuration)
EndFunction
Function DisplayApiGlobals()
EndFunction
Function OwnershipDebugMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowOwnershipDebugMenu()
	Return 0
EndFunction
Function ResetCell()
EndFunction
Function SetObjectOwnerNone()
EndFunction
Function GetObjectInfo()
EndFunction
Function SetCellPublic(Bool Public)
EndFunction
Function SetCellOwnerNone()
EndFunction
Function GetCellInfo()
EndFunction
Function ToggleHelloComments()
EndFunction
Function AddItemMenu()
EndFunction
Function GetKeywordsOnTarget()
EndFunction
Function OverlaysMenu(Bool IsShortcut = false)
EndFunction
Function ApplyOverlay(Actor akTarget, Bool Gender, String Node, String TextureToApply, Float Alpha, Int TintColor, Int EmissiveColor)
EndFunction
Int Function ShowOverlaysMenu()
	Return 0
EndFunction
String Function GetOverlayNode(Actor akActor, Bool Gender)
	Return ""
EndFunction
String Function SelectOverlayArea(String File = "")
	Return ""
EndFunction
Int Function SelectOverlaySlot(Actor akActor, Bool Gender, String Area)
	Return 0
EndFunction
Float Function SelectOverlayOpacity()
	Return 0.0
EndFunction
String Function GetInputTexture(String ExistingOverlay)
	Return ""
EndFunction
String Function SelectOverlayFromJsonList(String File, String Area)
	Return ""
EndFunction
Int Function GetOverlayColor(String Msg = "")
	Return 0
EndFunction
Function ClearLastOverlay()
EndFunction
String Function SelectOverlayJsonFile()
	Return ""
EndFunction
Function GetActorFactions()
EndFunction
Function ModEventsMenu()
EndFunction
Int Function ShowModEventsMenu()
	Return 0
EndFunction
Function EvictRootMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowEvictRootMenu()
	Return 0
EndFunction
Function EvictFromMenu(Bool IsShortcut = false)
EndFunction
Function UnEvictFromMenu(Bool IsShortcut = false)
EndFunction
Function EvictionFormsMenu()
EndFunction
Function EvictionReasonsMenu()
EndFunction
String Function GetCityStringFromInt(Int Loc)
	Return ""
EndFunction
Function LookAtDebug(Bool IsShortcut = false)
EndFunction
Int Function ShowLookAtDebugMenu()
	Return 0
EndFunction
Function SetIsNpcVar(Bool IsShortcut = false)
EndFunction
Int Function ShowSetIsNpcVarMenu()
	Return 0
EndFunction
Function TeleportMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowTeleportMenu()
	Return 0
EndFunction
Function TeleportToKennelMenu(Bool IsShortcut = false)
EndFunction
Function TeleportToQuartermasterMenu(Bool IsShortcut = false)
EndFunction
Int Function ShowCityLocationMenu()
	Return 0
EndFunction
Function LastAction()
EndFunction
String Function GetLastActionString()
	Return ""
EndFunction
Bool Function LastActionAvailable()
	Return False
EndFunction
Function BuildScriptArrays()
EndFunction
Function BuildOutfits()
EndFunction
Function BuildOutfitNames()
EndFunction
Function BuildHornyAnimsList()
EndFunction
Function BuildTonguesArray()
EndFunction
Function BuildLicGlobalArray()
EndFunction
String Function GetRandomHornyAnim()
	Return ""
EndFunction
String Function SnipToDecimalPlaces(String StrInput, Int Places)
	Return ""
EndFunction
String Function GetFormIdString(Form akForm)
	Return ""
EndFunction
String Function GetJigglesString()
	Return ""
EndFunction
Int Function GetFashionValues()
	Return 0
EndFunction
Function TransferDeviousDevices(ObjectReference DestRef)
EndFunction
Function TransferAllArmors(ObjectReference DestRef)
EndFunction
Function TransferBikiniArmors(ObjectReference DestRef)
EndFunction
Function TransferJewelry(ObjectReference DestRef)
EndFunction
Function TransferClothes(ObjectReference DestRef)
EndFunction
Function TransferLightArmor(ObjectReference DestRef)
EndFunction
Function TransferHeavyArmor(ObjectReference DestRef)
EndFunction
Function TransferAllWeapons(ObjectReference DestRef)
EndFunction
Function TransferAmmo(ObjectReference DestRef)
EndFunction
Function TransferIngredients(ObjectReference DestRef)
EndFunction
Function TransferAllPotions(ObjectReference DestRef)
EndFunction
Function TransferAllFood(ObjectReference DestRef)
EndFunction
Function TransferAllBooks(ObjectReference DestRef)
EndFunction
Function TransferAllMiscObjects(ObjectReference DestRef)
EndFunction
Function TransferGems(ObjectReference DestRef)
EndFunction
Function TransferCraftingMaterial(ObjectReference DestRef)
EndFunction
Function TransferClutter(ObjectReference DestRef)
EndFunction
Bool IsDressed = true
Bool TransferInProc = false
Int PlayerIsNpcVar
Int LastTongue = 0
Int UntieActorDeviceSelect
Int TongueSlotMask = 0x00004000
String[] HornyAnimsList
String[] TonguesList
String[] OutfitNames
String[] UntieActorDevices
Form[] StrippedItems
Form[] OutfitForms1
Form[] OutfitForms2
Form[] OutfitForms3
Form[] OutfitForms4
Form[] OutfitForms5
Form[] OutfitForms6
Form[] FollowersList
Actor UntieActor
ObjectReference XhairTarget
ObjectReference TransferFromContainer
Bool Property IsBendingOver = false Auto Hidden
Bool Property IsLookingSubmissively = false Auto Hidden
Bool FightControlsWereEnabled = true
Int Property AioKey = 34 Auto Hidden
Int Property StatusKey Auto Hidden
ObjectReference Property LookAtTarget Auto Hidden
ObjectReference Property _SLS_LookAtMarkerRef Auto
Formlist Property _SLS_TonguesList Auto
Formlist Property _SLS_BisSoapList Auto
Formlist Property _SLS_CumPotionAll Auto
Actor Property PlayerRef Auto
Keyword Property SexLabNoStrip Auto
Faction Property CWImperialFaction Auto
Faction Property CWSonsFaction Auto
Faction Property CWDialogueSoldierFaction Auto
Faction Property _SLS_NoHelloCommentsFact Auto
Perk Property _SLS_CrawlingPerk Auto
Spell Property _SLS_TeaseMyselfSpell Auto
Spell Property _SLS_ScreamForHelpSpell Auto
GlobalVariable Property _SLS_LicBikiniCurseIsWearingArmor Auto
GlobalVariable Property _SLS_BodyCoverStatus Auto
GlobalVariable Property _SLS_SearchGroundDistance Auto
GlobalVariable Property _SLS_BodyInflationScale Auto
Keyword Property _SLS_TongueKeyword Auto
Keyword Property LocTypeInn Auto
Quest Property _SLS_CoverMySelfQuest Auto
Quest Property _SLS_LookAtSearchQuest Auto
Quest Property _SLS_CombatTauntQuest Auto
Quest Property _SLS_BikiniExpTrainingQuest Auto
Quest Property _SLS_FlyYouFoolsQuest Auto
Quest Property _SLS_SpankRandomPeriodicQuest Auto
Quest Property _SLS_SearchGroundHostilesQuest Auto
Quest Property _SLS_SearchGroundQuest Auto
Quest Property _SLS_SubmitAliases Auto
Quest Property _SLS_HighlightItemsQuest Auto
Quest Property _SLS_SenseArousalQuest Auto
Quest Property _SLS_SenseCumFullnessQuest Auto
MiscObject Property _SLS_NeverAddedItem Auto
MiscObject Property Charcoal Auto
MiscObject Property Gold001 Auto
Message Property _SLS_SleepHereMsg Auto
Furniture Property Bedroll01 Auto
ImageSpaceModifier Property FadeToBlack Auto
Topic Property _SLS_AllInOneKeyGetAttention Auto
Topic Property _SLS_AioTauntTopic Auto
Topic Property _SLS_AioRetreat Auto
Sound Property _SLS_GetAttentionSM Auto
Sound Property _SLS_TauntSM Auto
Sound Property _SLS_RetreatSM Auto
Armor Property _SLS_DummyObject Auto
Idle Property pa_HugA Auto
_SLS_InterfaceAproposTwo Property Apro2 Auto
_SLS_InterfaceRapeTats Property RapeTats Auto
_SLS_InterfaceDevious Property Devious Auto
_SLS_InterfaceMilkAddict Property MilkAddict Auto
_SLS_InterfaceMme Property Mme Auto
_SLS_InterfaceFrostfall Property Frostfall Auto
_SLS_InterfaceBis Property Bis Auto
_SLS_InterfaceSexyMove Property SexyMove Auto
_SLS_InterfaceSpankThatAss Property Sta Auto
_SLS_InterfaceFhu Property Fhu Auto
_SLS_InterfaceSgo Property Sgo Auto
_SLS_AnimalFriend Property Friend Auto
_SLS_Dance Property Dance Auto
_SLS_CompulsiveSex Property CompulsiveSex Auto
_SLS_OrgasmFatigue Property Orgasmfatigue Auto
_SLS_LicenceUtil Property LicUtil Auto
_SLS_BikiniExpTraining Property BikiniExp Auto
_SLS_CumAddict Property CumAddict Auto
_SLS_CumSwallow Property CumSwallow Auto
_SLS_CoverMyself Property CoverMyself Auto
_SLS_Needs Property Needs Auto
_SLS_Api Property Api Auto
SLS_Utility Property Util Auto
SLS_Main Property Main Auto
SLS_Mcm Property Menu Auto
SLS_Init Property Init Auto
_SLS_AllInOneFavorite Property Fav Auto
SexlabFramework Property Sexlab Auto
