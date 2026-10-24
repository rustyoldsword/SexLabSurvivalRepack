Scriptname SLS_Mcm extends SKI_ConfigBase
Event OnConfigInit()
EndEvent
Function PlayerLoadsGame()
EndFunction
Function PapyrusUtilCheck()
EndFunction
Function BuildPages()
EndFunction
Function SetupMenuArrays()
EndFunction
Event OnConfigOpen()
EndEvent
Event OnConfigClose()
EndEvent
event OnPageReset(string page)
Endevent
event OnOptionHighlight(int option)
Endevent
Event OnOptionKeyMapChange(int option, int keyCode, string conflictControl, string conflictName)
EndEvent
Event OnOptionMenuOpen(int option)
EndEvent
Event OnOptionMenuAccept(int option, int index)
EndEvent
Event OnOptionSelect(int option)
EndEvent
event OnOptionDefault(int option)
Endevent
Function SetSliderOptions(Float Value, Float Default, Float Min, Float Max, Float Interval)
EndFunction
Event OnOptionSliderOpen(int option)
EndEvent
Event OnOptionSliderAccept(int option, float value)
EndEvent
Function ToggleTollGateLocks()
EndFunction
Function RestartInterfacePrompt(String IntSelect)
EndFunction
Function RestartIntErrorMsg(String ModName)
EndFunction
Function RestartInterface(Quest IntSelect)
EndFunction
Function SetSaltyCum(Bool SaltyCum)
EndFunction
Function TogglePushPlayer()
EndFunction
Function ToggleAssSlapping()
EndFunction
Function ToggleMinAV()
EndFunction
Function UpdateBellyScale()
EndFunction
Function ToggleBellyInflation()
EndFunction
Function ToggleLicences(Bool Enabled)
EndFunction
Function ToggleTollGateGuards()
EndFunction
Function ToggleCompassMechanics()
EndFunction
Function ToggleSleepDepriv()
EndFunction
Function DoSlaverunInit()
EndFunction
Function ToggleHalfNakedCover()
EndFunction
Function CheckHalfNakedCover()
EndFunction
Function ToggleHalfNakedStrips()
EndFunction
Function ToggleDeviousEffects()
EndFunction
Function ToggleTollDodging()
EndFunction
Function RefreshGuardSpotDistance()
EndFunction
Function TryHardcoreToggle()
EndFunction
Bool Function HardcoreToggleAllowed()
	Return False
EndFunction
Function ToggleTradeRestrictions()
EndFunction
String Function GetActorCrosshairRef()
	Return ""
EndFunction
Function DoTradeRestrictAddMerchant()
EndFunction
Function DoTradeRestrictRemoveMerchant()
EndFunction
Function AssignSlaverunMerchantRegion(Actor akTarget, Int Button)
EndFunction
Function UnAssignTradeRestrictMerchant(Actor akTarget)
EndFunction
Function DoTradeRestrictResetAllMerchants()
EndFunction
Function ImportTradeRestrictMerchants()
EndFunction
Function ImportSupportedMerchant(Formlist FlSelect, Actor akTarget)
EndFunction
Function TogglePpLoot()
EndFunction
Function BuildPpLootList()
EndFunction
Function ToggleFolContraBlock()
EndFunction
Function TogglePpSleepNpcPerk()
EndFunction
Function TogglePpFailHandle()
EndFunction
Function ImportEscorts()
EndFunction
Function AddEscort()
EndFunction
Function RemoveEscort()
EndFunction
String Function GetMageRankString()
	Return ""
EndFunction
String Function GetCompanionsRankString()
	Return ""
EndFunction
String Function GetCwSide()
	Return ""
EndFunction
Function AddQuestObjects()
EndFunction
Function ToggleKennelFollower()
EndFunction
Function BuildBikiniLists()
EndFunction
Function ClearBikiniLists()
EndFunction
Function ModFondleVoice(Bool AddToList)
EndFunction
Function InitLocJurisdictions()
EndFunction
String Function GetLocationJurisdictionString(Location Loc)
	Return ""
EndFunction
Function ModLocationJurisdiction(Bool AddLocation)
EndFunction
Formlist Function GetLocationJurisdictionList(Location Loc)
	Return None
EndFunction
Function RemoveLocationJurisdiction(Location Loc)
EndFunction
String Function GetLocationCurrentString()
	Return ""
EndFunction
Function ToggleDismemberment()
EndFunction
Function ToggleCurseTats()
EndFunction
Function SetInequalityEffects()
EndFunction
Function ToggleBikiniExp()
EndFunction
Function ImportLicenceExceptions()
EndFunction
Function AddWearableLanternExceptions()
EndFunction
Function AddRemoveLicenceException()
EndFunction
Function BuildSplashArray()
EndFunction
Function ToggleCumEffects()
EndFunction
Function ToggleAnimalBreeding()
EndFunction
Function ToggleBondFurn()
EndFunction
Function RefreshBikiniExpEffects()
EndFunction
Function ToggleBikiniCurse()
EndFunction
Function SetHorseCost(Int Cost)
EndFunction
Function GetEquippedList()
EndFunction
Function ModLicBuyBlock()
EndFunction
Function ToggleDebugMode()
EndFunction
Function UpdateMenuText(Int MenuOption, String Text)
EndFunction
Function LicShowApiBlockForms()
EndFunction
Function LicClearApiBlockForms()
EndFunction
Function BuildSexOptionsArrays()
EndFunction
Function RefreshBikiniCurseOverlay(Int index)
EndFunction
Function RefreshMagicCurseOverlay(Int index)
EndFunction
Function ToggleIneqSkills()
EndFunction
Function ToggleIneqBuySell()
EndFunction
Function ToggleCreatureEvents()
EndFunction
Function ToggleFastTravelDisable()
EndFunction
Function ToggleLicMagicCursedDevices()
EndFunction
Function ToggleBarefootMag()
EndFunction
Function ToggleCatCalling()
EndFunction
Function ToggleLicenceStyle()
EndFunction
Function ToggleGuardBehavLockpick()
EndFunction
Function ToggleGuardBehavDrugs()
EndFunction
Function ToggleGuardBehavWeapDrawn()
EndFunction
Function ToggleGuardBehavWeapEquip()
EndFunction
Function ToggleGuardBehavArmorEquip()
EndFunction
Function ToggleGuardComments()
EndFunction
Function ToggleCumAsLactacid(VoiceType Voice)
EndFunction
Function ToggleCumAsLactacidCustom()
EndFunction
Function ToggleProxSpank()
EndFunction
Function ToggleCumAddiction()
EndFunction
Function ToggleCoverMechanics()
EndFunction
Function ToggleCumAddictAutoSuckCreature()
EndFunction
String Function TidyFormString(Form akForm)
	Return ""
EndFunction
Function ToggleSexExp()
EndFunction
Function ResetSexExpStats()
EndFunction
Function ToggleIneqStrongFemaleFollowers()
EndFunction
Function SetStrongFollower(Actor Follower)
EndFunction
Function SetStrongFemale()
EndFunction
Function ImportStrongFemales()
EndFunction
Function AddRemoveChainCollars(Bool AddToList)
EndFunction
Function ReplaceVanillaMaps(Bool AddMaps)
EndFunction
Function ToggleStashTracking()
EndFunction
Function StashClearAllStashExceptions()
EndFunction
Function StashClearAllJsonExceptions()
EndFunction
Function StashClearAllTempExceptions()
EndFunction
Function SearchEscorts()
EndFunction
Function ReImportEscorts()
EndFunction
Function ClearAllEscorts()
EndFunction
Bool Function CanEnableSnowberry()
	Return False
EndFunction
Function SetGagSpeechDebuff()
EndFunction
Bool Function GetIsSleepDeprivationEnabled()
	Return False
EndFunction
Function ToggleNpcComments()
EndFunction
Function ToggleJiggles()
EndFunction
Function ToggleCompulsiveSex()
EndFunction
Function ToggleOrgasmFatigue()
EndFunction
Function TestBikiniArmor()
EndFunction
String Function TranslateBoolToYesNo(Bool Value)
	Return ""
EndFunction
Function ToggleCurfew(Bool Enabled)
EndFunction
Function LicenceToggleToggled()
EndFunction
Function ToggleTolls()
EndFunction
Function RefreshTollObjects()
EndFunction
Function ToggleAhegao()
EndFunction
Function BuildBikiniBreakdowns()
EndFunction
Function ToggleDropStealing()
EndFunction
Function ModifyVendorGold(Bool ImportSettings = false)
EndFunction
Function ToggleSteepFall()
EndFunction
Function ToggleCombatEquip()
EndFunction
Function LoadSettings()
EndFunction
Function SaveSettings()
EndFunction
Function SaveFormlistToJson(Formlist FlSelect, String FileName, String JsonKey, Bool ClearJsonKey = true)
EndFunction
Function LoadJsonFormsToFormlist(Formlist FlSelect, String FileName, String JsonKey, Bool RevertFl = true)
EndFunction
Int AllInOneKeyOID
Int ImportSettingsOID_T
Int ExportSettingsOID_T
Int SearchEscortsOID_T
Int AddEscortToListOID_T
Int RemoveEscortFromListOID_T
Int ClearAllEscortsOID_T
Int ImportEscortsFromJsonOID_T
Int LicGetEquipListOID_T
Int AddLicExceptionOID_T
Int TradeRestrictAddMerchantOID_T
Int TradeRestrictRemoveMerchantOID_T
Int TradeRestrictResetAllMerchantsOID_T
Int LicBikiniTriggerOID_T
Int StashAddRemoveExceptionOID_T
Int StashAddRemoveJsonExceptionsOID_T
Int StashAddRemoveTempExceptionsOID_T
Int StashAddRemoveAllExceptionsOID_T
Int LicBikiniHeelsOID
Int DiscountCollegeOID_T
Int DiscountCompanionsOID_T
Int DiscountCwOID_T
Int BikiniBuildListOID_T
Int BikiniClearListOID_T
Int BikiniChanceNoneOID_S
Int SexExpResetStatsOID_T
Int ModStrongFemaleOID_T
Int AddFondleToListOID_T
Int RemoveFondleFromListOID_T
Int FondleInfoOID_T
Int Property RunDevicePatchUpOID_T Auto Hidden
Int LicShowApiBlockFormsOID_T
Int LicClearApiBlockFormsOID_T
Int CurrentLocationOID_T
Int AddTownLocationOID_T
Int RemoveTownLocationOID_T
Int DismemberChanceActualOID_T
Int CumLactacidCustomOID_T
Int TollDodgedWhiterunOID_T
Int TollDodgedSolitudeOID_T
Int TollDodgedMarkarthOID_T
Int TollDodgedWindhelmOID_T
Int TollDodgedRiftenOID_T
Int CoverMyselfMechanicsOID
Int AssSlappingOID
Int ProxSpankCommentOID
Int EasyBedTrapsOID
Int CumBreathOID
Int CumBreathNotifyOID
Int DropItemsOID
Int SlsCreatureEventOID
Int AnimalBreedEnableOID
Int HardcoreModeOID
Int DebugModeOID
Int SlaverunAutoStartOID
Int MinAvToggleOID
Int FastTravelDisableOID
Int FtDisableIsNormalOID
Int ConstructableMapAndCompassOID
Int ReplaceMapsOID
Int CompassMechanicsOID
Int CumSwallowInflateOID
Int CumEffectsEnableOID
Int CumEffectsStackOID
Int CumAddictEnOID
Int CumAddictClampHungerOID
Int CumAddictBeastLevelsOID
Int SuccubusCumSwallowEnergyPerRankOID
Int CumLactacidAllOID
Int CumLactacidAllPlayableOID
Int FfRescueEventsOID
Int MilkDecCumBreathOID
Int PpLootEnableOID
Int PpFailHandleOID
Int PpSleepNpcPerkOID
Int HalfNakedEnableOID
Int HalfNakedStripsOID
Int SexExpEnableOID
Int DremoraCorruptionOID
Int SexMinStamMagRatesOID
Int SexRapeDrainsAttributesOID
Int CurfewEnableOID
Int IneqStatsOID
Int IneqCarryOID
Int InqSpeedOID
Int IneqDamageOID
Int IneqDestOID
Int IneqSkillsOID
Int IneqBuySellOID
Int IneqStrongFemaleFollowersOID
Int NormalKnockDialogOID
Int SleepDeprivOID
Int SaltyCumOID
Int BellyScaleEnableOID
Int GoldPerLevelOID
Int DoorLockDownOID
Int TollFollowersHardcoreOID
Int TollDodgingOID
Int TollDodgeGiftMenuOID
Int StashTrackEnOID
Int ContTypeCountsOID
Int OrgasmRequiredOID
Int LicencesEnableOID
Int LicencesSnowberryOID
Int BikiniLicFirstOID
Int LicBuyBackOID
Int LicBountyMustBePaidOID
Int FolContraBlockOID
Int FolContraKeysOID
Int FolTakeClothesOID
Int OrdinSupressOID
Int CurseTatsOID
Int ResponsiveEnforcersOID
Int PersistentEnforcersOID_S
Int RestrictTradeOID
Int BeggingTOID
Int BegSelfDegEnableOID
Int KennelExtraDevicesOID
Int KennelFollowerToggleOID
Int GuardCommentsOID
Int GuardBehavWeapDropOID
Int GuardBehavWeapEquipOID
Int GuardBehavWeapDrawnOID
Int GuardBehavArmorEquipOID
Int GuardBehavLockpickingOID
Int GuardBehavDrugsOID
Int GuardBehavShoutOID
Int DeviousEffectsEnableOID
Int DevEffNoGagTradingOID
Int BondFurnEnableOID
Int BikiniExpOID
Int BikiniExpReflexesOID
Int ReplaceMapsTimerOID_S
Int GoldWeightOID_S
Int FolGoldStealChanceOID_S
Int FolGoldSteamAmountOID_S
Int SlaverunAutoMinOID_S
Int SlaverunAutoMaxOID_S
Int HalfNakedBraOID_S
Int HalfNakedPantyOID_S
Int SexExpCorruptionCurrentOID_S
Int CockSizeBonusEnjFreqOID_S
Int RapeForcedSkoomaChanceOID_S
Int RapeMinArousalOID_S
Int SexMinStaminaRateOID_S
Int SexMinStaminaMultOID_S
Int SexMinMagickaRateOID_S
Int SexMinMagickaMultOID_S
Int AssSlapResistLossOID_S
Int ProxSpankCooloffOID_S
Int CumIsLactacidOID_S
Int AproTwoTrollHealAmountOID
Int AfCooloffBaseOID_S
Int AfCooloffBodyCumOID_S
Int AfCooloffCumInflationOID_S
Int AfCooloffPregnancyOID_S
Int AfCooloffCumSwallowOID_S
Int SlaTeaseCapOID_S
Int SlaFondleFadeOID_S
Int SlaTeaseFadeOID_S
Int SlaSeedFadeOID_S
Int DflowResistLossOID_S
Int CumSwallowInflateMultOID_S
Int CumEffectsMagMultOID_S
Int CumEffectsDurMultOID_S
Int CumpulsionChanceOID_S
Int CumRegenTimeOID_S
Int CumEffectVolThresOID_S
Int SuccubusCumSwallowEnergyMultOID_S
Int CumAddictionSpeedOID_S
Int CumAddictHungerRateOID_S
Int CumAddictHungerRateEffective
Int CumAddictionPerHourOID_S
Int CumSatiationOID_S
Int CumAddictBatheRefuseTimeOID_S
Int CumAddictReflexSwallowOID_S
Int CumAddictAutoSuckCreatureOID_S
Int CumAddictAutoSuckCooldownOID_S
Int CumAddictAutoSuckCreatureArousalOID_S
Int DeviousGagDebuffOID_S
Int BondFurnMilkFreqOID_S
Int BondFurnMilkFatigueMultOID_S
Int BondFurnMilkWillOID_S
Int BondFurnFreqOID_S
Int BondFurnFatigueMultOID_S
Int BondFurnWillOID_S
Int BarefootMagOIS_S
Int HorseCostOIS_S
Int CatCallVolOIS_S
Int CatCallWillLossOIS_S
Int GreetDistOIS_S
Int MinSpeedOID_S
Int MinCarryWeightOID_S
Int PpGoldChanceOfNoneOID_T
Int PpGoldLowChanceOID_S
Int PpGoldModerateChanceOID_S
Int PpGoldHighChanceOID_S
Int PpLootMinOID_S
Int PpLootMaxOID_S
Int PpLootChanceOfNoneOID_T
Int PpLootFoodChanceOID_S
Int PpLootGemsChanceOID_S
Int PpLootSoulgemsChanceOID_S
Int PpLootJewelryChanceOID_S
Int PpLootEnchJewelryChanceOID_S
Int PpLootPotionsChanceOID_S
Int PpLootKeysChanceOID_S
Int PpLootTomesChanceOID_S
Int PpLootCureChanceOID_S
Int PpCrimeGoldOID_S
Int PpFailDevicesOID_S
Int PpFailStealValueOID_S
Int PpFailDrugCountOID_S
Int DismemberCooldownOID_S
Int DismemberMaxAmpedLimbsOID_S
Int DismemberChanceOID_S
Int DismemberArmorBonusOID_S
Int DismemberDamageThresOID_S
Int DismemberHealthThresOID_S
Int AmpPriestHealCostOID_S
Int DismemberTrollCumOID
Int DismemberBathingOID
Int DismemberPlayerSayOID
Int IneqStatsValOID
Int IneqCarryValOID
Int IneqSpeedValOID
Int IneqDamageValOID
Int IneqDestValOID
Int IneqHealthCushionOID
Int IneqVendorGoldOID
Int KnockSlaveryChanceOID_S
Int SimpleSlaveryWeightOID_S
Int SdWeightOID_S
Int GluttedSpeedMultOID_S
Int CumFoodMultOID_S
Int CumDrinkMultOID_S
Int SkoomaSleepOID_S
Int MilkSleepMultOID_S
Int DrugEndFatigueIncOID_S
Int BaseBellyScaleOID_S
Int BellyScaleRnd00OID_S
Int BellyScaleRnd01OID_S
Int BellyScaleRnd02OID_S
Int BellyScaleRnd03OID_S
Int BellyScaleRnd04OID_S
Int BellyScaleRnd05OID_S
Int BellyScaleIneed00OID_S
Int BellyScaleIneed01OID_S
Int BellyScaleIneed02OID_S
Int BellyScaleIneed03OID_S
Int WarmBodiesOID_S
Int CumWetMultOID_S
Int CumExposureMultOID_S
Int MilkLeakWetOID_S
Int SwimCumCleanOID_S
Int SimpleSlaveryFFOID_S
Int SdDreamFFOID_S
Int EvictionLimitOID_S
Int SlaverunEvictionLimitOID_S
Int ConfiscationFineOID_S
Int ConfiscationFineSlaverunOID_S
Int TollCostGoldOID_S
Int SlaverunFactorOID
Int SlaverunJobFactorOID
Int TollCostDevicesOID_S
Int TollCostTattoosOID_S
Int TollCostDrugsOID_S
Int MaxTatsBodyOID_S
Int MaxTatsFaceOID_S
Int MaxTatsHandsOID_S
Int MaxTatsFeetOID_S
Int TollFollowersOID_S
Int TollDodgeHuntFreqOID_S
Int TollDodgeMaxGuardsOID_S
Int TollDodgeDetectDistMaxOID_S
Int TollDodgeDetectDistTownMaxOID_S
Int TollDodgeDisguiseBodyPenaltyOID_S
Int TollDodgeDisguiseHeadPenaltyOID_S
Int TollDodgeCurrentSpotDist
Int TollDodgeCurrentSpotDistTown
Int TollDodgeItemValueModOID_S
Int TollDodgeGracePeriodOID_S
Int EnforcerRespawnDurOID_S
Int TradeRestrictBribeOID_S
Int LicUnlockCostOID_S
Int LicBlockChanceOID_S
Int LicFactionDiscountOID_S
Int LicShortDurOID_S
Int LicLongDurOID_S
Int LicWeapShortCostOID_S
Int LicWeapLongCostOID_S
Int LicWeapPerCostOID_S
Int LicMagicShortCostOID_S
Int LicMagicLongCostOID_S
Int LicMagicPerCostOID_S
Int LicArmorShortCostOID_S
Int LicArmorLongCostOID_S
Int LicArmorPerCostOID_S
Int LicBikiniEnableOID
Int LicBikiniCurseEnableOID
Int LicMagicEnableOID
Int LicMagicCursedDevicesOID
Int LicMagicChainCollarsOID
Int LicBikiniHeelHeightOID_S
Int LicBikiniShortCostOID_S
Int LicBikiniLongCostOID_S
Int LicBikiniPerCostOID_S
Int LicClothesShortCostOID_S
Int LicClothesLongCostOID_S
Int LicClothesPerCostOID_S
Int EnforcersMinOID_S
Int EnforcersMaxOID_S
Int RoadDistOID_S
Int StealXItemsOID_S
Int BegNumItemsOID_S
Int BegGoldOID_S
Int BegMwaCurseChanceOID_S
Int KennelSafeCellCostOID_S
Int KennelCreatureChanceOID_S
Int KennelRapeChancePerHourOID_S
Int KennelSlaveRapeTimeMinOID_S
Int KennelSlaveRapeTimeMaxOID_S
Int BikiniExpPerLevelOID_S
Int BikiniExpTrainOID_S
Int BikiniExpUntrainOID_S
Int BikiniDropsVendorCityOID_S
Int BikiniDropsVendorTownOID_S
Int BikiniDropsVendorKhajiitOID_S
Int BikiniDropsChestOID_S
Int BikiniDropsChestOrnateOID_S
Int BikiniChanceHideOID_S
Int BikiniChanceLeatherOID_S
Int BikiniChanceIronOID_S
Int BikiniChanceSteelOID_S
Int BikiniChanceSteelPlateOID_S
Int BikiniChanceDwarvenOID_S
Int BikiniChanceFalmerOID_S
Int BikiniChanceWolfOID_S
Int BikiniChanceBladesOID_S
Int BikiniChanceEbonyOID_S
Int BikiniChanceDragonboneOID_S
Int PushEventsDB
Int ProxSpankNpcDB
Int ProxSpankCoverDB
Int CumAddictAutoSuckStageDB
Int LicClothesEnableDB
Int BegSexAggDB
Int BegSexVictimDB
Int KennelSexAggDB
Int KennelSexVictimDB
Int CompassHideMethodDB
Int DevEffLockpickDiffDB
Int DevEffPickpocketDiffDB
Int TollSexAggDB
Int TollSexVictimDB
Int DismembermentsDB
Int DismemberProgressionDB
Int DismemberWeaponsDB
Int DismemberDepthMaxArmsDB
Int DismemberDepthMaxLegsDB
Int LicenceStyleDB
Int FollowerLicStyleDB
Int LicBuyBackPriceDB
Int LicEquipListDB
Int BikiniCurseAreaDB
Int MagicCurseAreaDB
Int SexExpCorruptionDB
Bool IsInMcm = false
Bool DoSlaverunInitOnClose = false
Bool DoToggleCatCalling = false
Bool HardcoreMode = false
Bool IsHardcoreLocked = false
Bool LicMagicChainCollars = false
Bool TradeRestrictions = true
Bool PpLootEnable = true
Bool DoToggleCumEffects = false
Bool DoPpLvlListbuildOnClose = false
Bool DoTogglePpFailHandle = false
Bool DoInequalityRefresh = false
Bool DoToggleBikiniExp = false
Bool DoToggleAnimalBreeding = false
Bool DoTogglePushEvents = false
Bool DoToggleHalfNakedCover = false
Bool DoToggleIneqStrongFemaleFollowers = false
Bool DoToggleSexExp = false
Bool DoToggleHeelsRequired = false
Bool DoToggleStashTracking = false
Bool DoStashAddRemoveException = false
Bool CumEffectsEnable = true
Bool BikiniExpT = true
Bool InequalitySkills = true
Bool InequalityBuySell = true
Bool IneqStrongFemaleFollowers = false
Bool TollFollowersHardcore = false
Bool Property CoverMyselfMechanics = true Auto Hidden
Bool AssSlappingEvents = true
Bool Property BellyScaleEnable = true Auto Hidden
Bool Property HalfNakedEnable = false Auto Hidden
Bool SleepDepriv = true
Bool SlaverunAutoStart = false
Bool DoDeviousEffectsChange = false
Bool DoToggleBondFurn = false
Bool Property TollDodging = true Auto Hidden
Bool DoTollDodgingToggle = false
Bool FolContraBlock = true
Bool PpFailHandle = true
Bool PpSleepNpcPerk = true
Bool DoToggleLicenceStyle = false
Bool DoToggleGuardComments = false
Bool DoToggleGuardBehavWeapDrawn = false
Bool DoToggleGuardBehavLockpick = false
Bool DoToggleGuardBehavArmorEquip = false
Bool DoToggleGuardBehavWeapEquip = false
Bool DoToggleGuardBehavDrugs = false
Bool GuardComments = true
Bool Property GuardBehavWeapDrawn = true Auto Hidden
Bool Property GuardBehavArmorEquip = false Auto Hidden
Bool Property GuardBehavWeapEquip = true Auto Hidden
Bool GuardBehavLockpicking = true
Bool GuardBehavDrugs = true
Bool DoToggleProxSpank = false
Bool DoToggleBarefootSpeed = false
Bool DoToggleCumAddiction = false
Bool DoToggleCoverMechanics = false
Bool DoToggleCumAddictAutoSuckCreature = false
Bool Property SnowberryEnable = false Auto Hidden
Bool DoToggleBellyInflation = false
Bool Property CumLactacidAll = false Auto Hidden
Bool Property CumLactacidAllPlayable = false Auto Hidden
Int ProxSpankNpcType = 1
Int TradeRestrictBribe = 50
Int SurvivalHorseCost = 6000
Float PpGoldLowChance = 60.0
Float PpGoldModerateChance = 20.0
Float PpGoldHighChance = 2.0
Int PpLootLootMin = 0
Int PpLootLootMax = 8
Float PpLootFoodChance = 25.0
Float PpLootGemsChance = 15.0
Float PpLootSoulgemsChance = 10.0
Float PpLootJewelryChance = 15.0
Float PpLootEnchJewelryChance = 5.0
Float PpLootPotionsChance = 10.0
Float PpLootKeysChance = 10.0
Float PpLootTomesChance = 5.0
Float PpLootCureChance = 5.0
Float GreetDist = 150.0
Int SelectedEquip = 0
Int BikiniDropsVendorCity = 30
Int BikiniDropsVendorTown = 16
Int BikiniDropsVendorKhajiit = 12
Int BikiniDropsChest = 6
Int BikiniDropsChestOrnate = 10
Float BikiniChanceHide = 10.0
Float BikiniChanceLeather = 10.0
Float BikiniChanceIron = 10.0
Float BikiniChanceSteel = 11.0
Float BikiniChanceSteelPlate = 8.0
Float BikiniChanceDwarven = 6.0
Float BikiniChanceFalmer = 6.0
Float BikiniChanceWolf = 6.0
Float BikiniChanceBlades = 2.0
Float BikiniChanceEbony = 1.0
Float BikiniChanceDragonbone = 0.5
Float Property IneqFemaleVendorGoldMult = 1.0 Auto Hidden
Float Property IneqStatsVal = 40.0 Auto Hidden
Float IneqHealthCushion = 20.0
Float IneqCarryVal = 150.0
Float IneqSpeedVal = 10.0
Float IneqDamageVal = 20.0
Float IneqDestVal = 20.0
Int Property AmpType = 0 Auto Hidden
Int Property AmpDepth = 2 Auto Hidden
Int Property MaxAmpDepthArms = 1 Auto Hidden
Int Property MaxAmpDepthLegs = 1 Auto Hidden
Int Property DismemberDamageThres = 3 Auto Hidden
Int Property DismemberWeapon = 0 Auto Hidden
Int Property MaxAmpedLimbs = 2 Auto Hidden
Float Property DismemberChance = 90.0 Auto Hidden
Float Property DismemberArmorBonus = 5.0 Auto Hidden
Float Property DismemberCooldown = 0.1 Auto Hidden
Float Property DismemberHealthThres = 110.0 Auto Hidden
Int[] Property SlotMasks Auto Hidden
String[] SplashArray
String[] PushEventsType
String[] ClothesLicenceMethod
String[] HeavyBondageDifficulty
String[] SexAggressiveness
String[] SexPlayerIsVictim
String[] FollowerLicStyles
String[] CompassHideMethods
String[] EquipSlotStrings
Form[] EquipSlots
String[] AmputationTypes
String[] AmputationDepth
String[] MaxAmputationDepthArms
String[] MaxAmputationDepthLegs
String[] DismemberWeapons
String[] Property OverlayAreas Auto Hidden
String[] BuyBackPrices
String[] LicenceStyleList
String[] ProxSpankNpcList
String[] ProxSpankRequiredCoverList
String[] CumHungerStrings
String[] SexExpCreatureCorruption
Int Property FolGoldSteamAmount = 30 Auto Hidden
Int Property PpCrimeGold = 100 Auto Hidden
Int Property PpFailDrugCount = 2 Auto Hidden
Int Property AproTwoTrollHealAmount = 200 Auto Hidden
Int Property BondFurnMilkWill = 4 Auto Hidden
Int Property BondFurnWill = 2 Auto Hidden
Int Property SwimCumClean = 12 Auto Hidden
Int Property ConfiscationFine = 100 Auto Hidden
Int Property ConfiscationFineSlaverun = 200 Auto Hidden
Int Property TollSexAgg = 0 Auto Hidden
Int Property TollSexVictim = 0 Auto Hidden
Int Property MaxTatsBody = 6 Auto Hidden
Int Property MaxTatsFace = 3 Auto Hidden
Int Property MaxTatsHands = 0 Auto Hidden
Int Property MaxTatsFeet = 0 Auto Hidden
Int Property BegNumItems = 2 Auto Hidden
Int Property BegSexAgg = 0 Auto Hidden
Int Property BegSexVictim = 0 Auto Hidden
Int Property HalfNakedBra = 56 Auto Hidden
Int Property HalfNakedPanty = 49 Auto Hidden
Int Property SexExpCorruption = 0 Auto Hidden
Int Property TollDodgeMaxGuards = 6 Auto Hidden
Int Property BikiniCurseArea = 0 Auto Hidden
Int Property MagicCurseArea = 1 Auto Hidden
Int Property EnforcersMin = 2 Auto Hidden
Int Property BuyBackPrice = 2 Auto Hidden
Int Property EnforcersMax= 4 Auto Hidden
Int Property BegQuantity = 2 Auto Hidden
Int Property KennelSafeCellCost = 40 Auto Hidden
Int Property PushEvents = 0 Auto Hidden
Int Property DevEffLockpickDiff = 1 Auto Hidden
Int Property DevEffPickpocketDiff = 1 Auto Hidden
Int Property KennelSlaveRapeTimeMin = 10 Auto Hidden
Int Property KennelSlaveRapeTimeMax = 40 Auto Hidden
Int Property KennelSexAgg = 2 Auto Hidden
Int Property KennelSexVictim = 1 Auto Hidden
Int Property CumHungerAutoSuck = 2 Auto Hidden
Int Property CompassHideMethod = 0 Auto Hidden
Float Property FolGoldStealChance = 50.0 Auto Hidden
Float Property BarefootMag = 50.0 Auto Hidden
Float Property CatCallVol = 20.0 Auto Hidden
Float Property CatCallWillLoss = 1.0 Auto Hidden
Float Property SlaverunAutoMin = 2.0 Auto Hidden
Float Property SlaverunAutoMax = 14.0 Auto Hidden
Float Property AssSlapResistLoss = 1.0 Auto Hidden
Float Property ProxSpankCooloff = 10.0 Auto Hidden
Float Property CockSizeBonusEnjFreq = 3.0 Auto Hidden
Float Property RapeForcedSkoomaChance = 35.0 Auto Hidden
Float Property RapeMinArousal = 50.0 Auto Hidden
Float Property SexMinStaminaRate = 2.5 Auto Hidden
Float Property SexMinStaminaMult = 60.0 Auto Hidden
Float Property SexMinMagickaRate = 1.5 Auto Hidden
Float Property SexMinMagickaMult = 50.0 Auto Hidden
Float Property KennelRapeChancePerHour = 20.0 Auto Hidden
Float Property MinSpeedMult = 50.0 Auto Hidden
Float Property MinCarryWeight = 50.0 Auto Hidden
Float Property ReplaceMapsTimer = 180.0 Auto Hidden
Float Property GoldWeight = 0.01 Auto Hidden
Float Property GluttedSpeed = 10.0 Auto Hidden
Float Property SkoomaSleep = 1.0 Auto Hidden
Float Property MilkSleepMult = 1.0 Auto Hidden
Float Property DrugEndFatigueInc = 0.25 Auto Hidden
Float Property CumIsLactacid = 0.0 Auto Hidden
Float Property CumSwallowInflateMult = 1.0 Auto Hidden
Float Property CumEffectsMagMult = 1.0 Auto Hidden
Float Property CumEffectsDurMult = 1.0 Auto Hidden
Float Property CumpulsionChance = 25.0 Auto Hidden
Float Property CumRegenTime = 24.0 Auto Hidden
Float Property CumEffectVolThres = 85.0 Auto Hidden
Float Property SuccubusCumSwallowEnergyMult = 1.0 Auto Hidden
Float Property CumAddictionHungerRate = 0.1 Auto Hidden
Float Property CumAddictionSpeed = 1.0 Auto Hidden
Float Property CumAddictionDecayPerHour = 1.0 Auto Hidden
Float Property CumSatiation = 1.0 Auto Hidden
Float Property CumAddictBatheRefuseTime = 6.0 Auto Hidden
Float Property CumAddictAutoSuckCreature = 1.0 Auto Hidden
Float Property CumAddictAutoSuckCooldown = 6.0 Auto Hidden
Float Property CumAddictAutoSuckCreatureArousal = 70.0 Auto Hidden
Float Property CumAddictReflexSwallow = 1.0 Auto Hidden
Float Property DflowResistLoss = 5.0 Auto Hidden
Float Property DeviousGagDebuff = 80.0 Auto Hidden
Float Property BondFurnMilkFreq = 6.0 Auto Hidden
Float Property BondFurnMilkFatigueMult = 1.0 Auto Hidden
Float Property BondFurnFreq = 3.0 Auto Hidden
Float Property BondFurnFatigueMult = 1.0 Auto Hidden
Float Property KnockSlaveryChance = 3.0 Auto Hidden
Float Property SimpleSlaveryWeight = 50.0 Auto Hidden
Float Property SdWeight = 50.0 Auto Hidden
Float Property WarmBodies = -3.0 Auto Hidden
Float Property CumWetMult = 1.0 Auto Hidden
Float Property CumExposureMult = 1.0 Auto Hidden
Float Property MilkLeakWet = 50.0 Auto Hidden
Float Property SimpleSlaveryFF = 50.0 Auto Hidden
Float Property SdDreamFF = 50.0 Auto Hidden
Float Property EvictionLimit = 500.0 Auto Hidden
Float Property SlaverunEvictionLimit = 200.0 Auto Hidden
Float Property TollDodgeHuntFreq = 1.5 Auto Hidden
Float Property TollDodgeDisguiseBodyPenalty = 0.75 Auto Hidden
Float Property TollDodgeDisguiseHeadPenalty = 0.75 Auto Hidden
Float Property TollDodgeItemValueMod = 1.0 Auto Hidden
Float Property TollDodgeGracePeriod = 2.0 Auto Hidden
Float Property GuardSpotDistNom = 512.0 Auto Hidden
Float Property GuardSpotDistTown = 768.0 Auto Hidden
Float Property EnforcerRespawnDur = 7.0 Auto Hidden
Float Property LicBlockChance = 70.0 Auto Hidden
Float Property RoadDist = 8192.0 Auto Hidden
Float Property StealXItems = 25.0 Auto Hidden
Float Property BegGold = 1.0 Auto Hidden
Float Property BegMwaCurseChance = 50.0 Auto Hidden
Float Property KennelCreatureChance = 50.0 Auto Hidden
Float Property BikTrainingSpeed = 1.0 Auto Hidden
Float Property BikUntrainingSpeed = 0.5 Auto Hidden
Bool Property CumSwallowInflate = true Auto Hidden
Bool Property CumEffectsStack = true Auto Hidden
Bool Property SuccubusCumSwallowEnergyPerRank = true Auto Hidden
Bool Property CumAddictEn = true Auto Hidden
Bool Property CumAddictClampHunger = true Auto Hidden
Bool Property CumAddictBeastLevels = false Auto Hidden
Bool Property MilkDecCumBreath = false Auto Hidden
Bool Property DropItems = true Auto Hidden
Bool Property EasyBedTraps = true Auto Hidden
Bool Property AnimalBreedEnable = false Auto Hidden
Bool Property CumBreath = true Auto Hidden
Bool Property CumBreathNotify = true Auto Hidden
Bool Property FollowersStealGold = true Auto Hidden
Bool Property FastTravelDisable = true Auto Hidden
Bool Property FtDisableIsNormal = true Auto Hidden
Bool Property ReplaceMaps = true Auto Hidden
Bool Property CompassMechanics = true Auto Hidden
Bool Property MinAvToggleT = true Auto Hidden
Bool Property FfRescueEvents = true Auto Hidden
Bool Property DoorLockDownT = true Auto Hidden
Bool Property StashTrackEn = true Auto Hidden
Bool Property ContTypeCountsT = true Auto Hidden
Bool Property OrgasmRequired = true Auto Hidden
Bool Property SaltyCum = false Auto Hidden
Bool Property HalfNakedStrips = false Auto Hidden
Bool Property SexExpEn = true Auto Hidden
Bool Property DremoraCorruption = false Auto Hidden
Bool Property SexMinStamMagRates = true Auto Hidden
Bool Property RapeDrainsAttributes = true Auto Hidden
Bool Property CurfewEnable = true Auto Hidden
Bool Property DeviousEffectsEnable = false Auto Hidden
Bool Property DevEffNoGagTrading = false Auto Hidden
Bool Property BondFurnEnable = true Auto Hidden
Bool Property KennelFollowerToggle = true Auto Hidden
Bool Property DismemberTrollCum = true Auto Hidden
Bool Property DismemberBathing = true Auto Hidden
Bool Property DismemberPlayerSay = true Auto Hidden
Quest Property _SLS_AssSlapQuest Auto
Quest Property _SLS_BellyInflationQuest Auto
Quest Property _SLS_LicenceAliases Auto
Quest Property _SLS_MapAndCompassQuest Auto
Quest Property _SLS_SleepDeprivationQuest Auto
Quest Property _SLS_SlaverunKickerQuest Auto
Quest Property _SLS_HalfNakedCoverQuest Auto
Quest Property _SLS_DeviousEffectsQuest Auto
Quest Property _SLS_TollDodgeHuntQuest Auto
Quest Property _SLS_TollDodgeQuest Auto
Quest Property _SLS_LicenceTradersQuest Auto
Quest Property _SLS_LicFollowerEnforcementDumbQuest Auto
Quest Property _SLS_PickPocketFailDetectQuest Auto
Quest Property _SLS_LicTownCheckEnforcerAliases Auto
Quest Property _SLS_LicTownCheckPlayerAliasQuest Auto
Quest Property _SLS_LicTownCheckQuest Auto
Quest Property _SLS_AmputationQuest Auto
Quest Property _SLS_InequalityRefreshQuest Auto
Quest Property _SLS_BikiniExpTrainingQuest Auto
Quest Property _SLS_CumEffectsQuest Auto
Quest Property _SLS_AnimalFriendQuest Auto
Quest Property _SLS_AnimalFriendAliases Auto
Quest Property _SLS_DeviousFurnitureQuest Auto
Quest Property _SLS_LicenceBuyBlockerQuest Auto
Quest Property _SLS_CatCallsQuest Auto
Quest Property _SLS_GuardWarnLockpickQuest Auto
Quest Property _SLS_GuardWarnDrugsQuest Auto
Quest Property _SLS_GuardWarnArmorEquippedQuest Auto
Quest Property _SLS_GuardWarnArmorEquippedDetectQuest Auto
Quest Property _SLS_GuardWarnWeapEquippedQuest Auto
Quest Property _SLS_GuardWarnWeapEquippedDetectQuest Auto
Quest Property _SLS_GuardWarnWeapDrawnQuest Auto
Quest Property _SLS_GuardWarnWeapDrawnDetectionQuest Auto
Quest Property _SLS_GuardHellosQuest Auto
Quest Property _SLS_HelloSpankAnythingQuest Auto
Quest Property _SLS_HelloSpankGuardsQuest Auto
Quest Property _SLS_HelloSpankGuardsAndMenQuest Auto
Quest Property _SLS_HelloSpankMenQuest Auto
Quest Property _SLS_HelloSpankWomenQuest Auto
Quest Property _SLS_CoverMySelfQuest Auto
Quest Property _SLS_CumAddictAutoSuckCreatureQuest Auto
Quest Property _SLS_SexExperienceQuest Auto
Quest Property _SLS_SexCockSizeQuest Auto
Quest Property _SLS_StashTrack Auto
Quest Property _SLS_StashAddExceptionQuest Auto
Quest Property _SLS_FindEscortsQuest Auto
Quest Property _SLS_LicenceQuest Auto
Quest Property _SLS_LicenceSnowberryQuest Auto
Quest Property CW01A Auto
Quest Property CW01B Auto
Quest Property Stables Auto
Quest Property MQ101 Auto
Actor Property PlayerRef Auto
Faction Property PotentialFollowerFaction Auto
Faction Property PotentialHireling Auto
Faction Property CollegeofWinterholdFaction Auto
Faction Property CompanionsFaction Auto
Faction Property _SLS_IneqStrongFemaleFact Auto
ObjectReference Property _SLS_LicenceGateActJkRef Auto
ObjectReference Property _SLS_LicenceDumpRef Auto
Spell Property _SLS_MagicLicenceCurse Auto
Spell Property _SLS_InequalitySpell Auto
Spell Property _SLS_BikiniExpSpell Auto
Spell Property _SLS_DebugGetActorPackSpell Auto
Spell Property _SLS_DebugGetActorVoiceTypeSpell Auto
Spell Property _SLS_WeaponReadySpell Auto
Spell Property _SLS_CumAddictHungerSpell Auto
Spell Property _SLS_CumAddictStatusSpell Auto
Spell Property _SLS_LicInspLostSightSpell Auto
MagicEffect Property _SLS_MagicLicenceCollarMgef Auto
MagicEffect Property _SLS_LicBikiniCurseInactiveMgef Auto
MagicEffect Property _SLS_LicBikiniCurseStamina Auto
Perk Property _SLS_CreatureTalk Auto
Perk Property _SLS_IncPickpocketLootPerk Auto
Perk Property _SLS_PickpocketSleepBonusPerk Auto
Perk Property _SLS_InequalityBuySellPerk Auto
Perk Property _SLS_InequalitySkillsPerk Auto
Perk Property _SLS_BikiniExpPerk Auto
Formlist Property _SLS_LicenceGateActList Auto
Formlist Property _SLS_TraderListExceptions Auto
Formlist Property _SLS_TraderListAll Auto
Formlist Property _SLS_TraderBaseListAll Auto
Formlist Property _SLS_TraderListFalkreath Auto
Formlist Property _SLS_TraderListMarkarth Auto
Formlist Property _SLS_TraderListMorthal Auto
Formlist Property _SLS_TraderListRavenRock Auto
Formlist Property _SLS_TraderListRiften Auto
Formlist Property _SLS_TraderListRiverwood Auto
Formlist Property _SLS_TraderListSolitude Auto
Formlist Property _SLS_TraderListWhiterun Auto
Formlist Property _SLS_TraderListWindhelm Auto
Formlist Property _SLS_TraderListWinterhold Auto
Formlist Property _SLS_TraderListDawnstar Auto
Formlist Property _SLS_EscortsList Auto
Formlist Property _SLS_QuestItems Auto
Formlist Property _SLS_FondleableVoices Auto
Formlist Property _SLS_LocsWhiterun Auto
Formlist Property _SLS_LocsSolitude Auto
Formlist Property _SLS_LocsMarkarth Auto
Formlist Property _SLS_LocsWindhelm Auto
Formlist Property _SLS_LocsRiften Auto
Formlist Property _SLS_LicExceptionsWeapon Auto
Formlist Property _SLS_LicExceptionsArmor Auto
Formlist Property _SLS_CumHasLactacidVoices Auto
Formlist Property _SLS_StaticMapList Auto
Formlist Property _SLS_ActivatableMapList Auto
Formlist Property _SLS_EscortsVanilla Auto
Formlist Property _SLS_EscortsBaseList Auto
Formlist Property _SLS_CumLactacidVoicesList Auto
GlobalVariable Property _SLS_TollCost Auto
GlobalVariable Property _SLS_TollFollowersRequired Auto
GlobalVariable Property _SLS_KennelCellCost Auto
GlobalVariable Property _SLS_LicCostShort Auto
GlobalVariable Property _SLS_LicCostLong Auto
GlobalVariable Property _SLS_LicCostPer Auto
GlobalVariable Property _SLS_BeggingDialogT Auto
GlobalVariable Property _SLS_TollDodgeHuntRadius Auto
GlobalVariable Property _SLS_TollDodgeHuntRadiusTown Auto
GlobalVariable Property _SLS_RestrictTradeBribe Auto
GlobalVariable Property _SLS_PickPocketFailStealValue Auto
GlobalVariable Property _SLS_BegSelfDegradationEnable Auto
GlobalVariable Property _SLS_ResponsiveEnforcers Auto
GlobalVariable Property _SLS_KennelExtraDevices Auto
GlobalVariable Property _SLS_AmpPriestHealCost Auto
GlobalVariable Property _SLS_BikiniExpReflexes Auto
GlobalVariable Property _SLS_BikiniExpLevel Auto
GlobalVariable Property _SLS_GuardBehavShoutEn Auto
GlobalVariable Property _SLS_GuardBehavWeapDropEn Auto
GlobalVariable Property _SLS_ProxSpankRequiredCover Auto
GlobalVariable Property _SLS_CumAddictionPool Auto
GlobalVariable Property _SLS_CumAddictionHunger Auto
GlobalVariable Property _SLS_CumHunger0 Auto
GlobalVariable Property _SLS_CumHunger1 Auto
GlobalVariable Property _SLS_CumHunger2 Auto
GlobalVariable Property _SLS_CumHunger3 Auto
GlobalVariable Property _SLS_CoveringNakedStatus Auto
GlobalVariable Property _SLS_BodyCoverStatus Auto
GlobalVariable Property _SLS_LicUnlockCost Auto
GlobalVariable Property _SLS_LicInspPersistence Auto
GlobalVariable Property _SLS_MapAndCompassRecipeEnable Auto
GlobalVariable Property _SLS_IneqCarry Auto
GlobalVariable Property _SLS_IneqDamage Auto
GlobalVariable Property _SLS_IneqDestruction Auto
GlobalVariable Property _SLS_IneqSpeed Auto
GlobalVariable Property _SLS_IneqStat Auto
GlobalVariable Property _SLS_IneqDebuffPlusCushion Auto
GlobalVariable Property HorseCost Auto
MiscObject Property Gold001 Auto
Message Property _SLS_TradeRestrictSetMerchant Auto
Message Property _SLS_GetLocationJurisdiction Auto
Message Property _SLS_AddEscortsMsg Auto
ReferenceAlias Property _SLS_TollGateWhiterunInside Auto
ReferenceAlias Property _SLS_TollGateSolitudeInside Auto
ReferenceAlias Property _SLS_TollGateRiftenMainInside Auto
ReferenceAlias Property _SLS_TollGateWindhelmInterior Auto
ReferenceAlias Property _SLS_TollGateMarkarthInterior Auto
Location Property _SLS_KennelWhiterunLocation Auto
Keyword Property SexlabNoStrip Auto
LeveledItem Property _SLS_PpLootRootList Auto
LeveledItem Property _SLS_PpGoldRoot Auto
LeveledItem Property _SLS_PpLootEmptyList Auto
LeveledItem Property _SLS_PpLootFoodList Auto
LeveledItem Property _SLS_PpLootGemsList Auto
LeveledItem Property _SLS_PpLootSoulgemsList Auto
LeveledItem Property _SLS_PpLootJewelryList Auto
LeveledItem Property _SLS_PpLootEnchJewelryList Auto
LeveledItem Property _SLS_PpLootPotionsList Auto
LeveledItem Property _SLS_PpLootKeysList Auto
LeveledItem Property _SLS_PpLootTomesList Auto
Potion Property CureDisease Auto
LeveledItem Property _SLS_PpGoldLow Auto
LeveledItem Property _SLS_PpGoldModerate Auto
LeveledItem Property _SLS_PpGoldHigh Auto
LeveledItem Property _SLS_BikiniArmorsListHide Auto
LeveledItem Property _SLS_BikiniArmorsListLeather Auto
LeveledItem Property _SLS_BikiniArmorsListIron Auto
LeveledItem Property _SLS_BikiniArmorsListSteel Auto
LeveledItem Property _SLS_BikiniArmorsListSteelPlate Auto
LeveledItem Property _SLS_BikiniArmorsListDwarven Auto
LeveledItem Property _SLS_BikiniArmorsListFalmer Auto
LeveledItem Property _SLS_BikiniArmorsListWolf Auto
LeveledItem Property _SLS_BikiniArmorsListBlades Auto
LeveledItem Property _SLS_BikiniArmorsListEbony Auto
LeveledItem Property _SLS_BikiniArmorsListDragonbone Auto
LeveledItem Property _SLS_BikiniArmorsEntryPointChest Auto
LeveledItem Property _SLS_BikiniArmorsEntryPointChestOrnate Auto
LeveledItem Property _SLS_BikiniArmorsEntryPointVendorCity Auto
LeveledItem Property _SLS_BikiniArmorsEntryPointVendorTown Auto
LeveledItem Property _SLS_BikiniArmorsEntryPointVendorKhajiit Auto
LeveledItem Property _SLS_BikiniArmorsList Auto
Form Property BikiniCurseTriggerArmor Auto Hidden
SLS_Init Property Init Auto
SLS_Main Property Main Auto
SLS_MinAv Property MinAv Auto
SLS_Utility Property Util Auto
SLS_GluttonyInflationScript Property Gluttony Auto
_SLS_Needs Property Needs Auto
_SLS_LicenceUtil Property LicUtil Auto
_SLS_MapAndCompassAlias Property Compass Auto
_SLS_HalfNakedCover Property HalfNakedCover Auto
_SLS_DeviousEffects Property DeviousEffects Auto
_SLS_TollDodgeDisguise Property DodgeDisguise Auto
_SLS_TollDodge Property TollDodge Auto
_SLS_AnimalFriend Property AnimalFriend Auto
_SLS_Amputation Property Amputation Auto
_SLS_BikiniExpTraining Property BikiniExp Auto
_SLS_LicBikiniCurse Property BikiniCurse Auto
SLS_EvictionTrack Property Eviction Auto
_SLS_LicenceBuyBlocker Property LicBuyBlocker Auto
_SLS_DeviousEffectsGagTrade Property GagTrade Auto
_SLS_CumAddict Property CumAddict Auto
_SLS_CoverMyself Property CoverMyself Auto
_SLS_CumSwallow Property CumSwallow Auto
SLS_StashTrackPlayer Property StashTrack Auto
_SLS_MapAndCompassAlias Property MapAndCompass Auto
_SLS_AllInOneKey Property AllInOne Auto
_SLS_ForcedDrugging Property ForceDrug Auto
_SLS_FashionRape Property FashionRape Auto
_SLS_TollUtil Property TollUtil Auto
_SLS_LocTrackCentral Property LocTrack Auto
_SLS_Trauma Property Trauma Auto
_SLS_SteepFall Property SteepFall Auto
_SLS_InterfaceRnd Property Rnd Auto
_SLS_InterfaceIneed Property Ineed Auto
_SLS_InterfaceFrostfall Property Frostfall Auto
_SLS_InterfaceSlaverun Property Slaverun Auto
_SLS_InterfacePaySexCrime Property Psc Auto
_SLS_InterfaceDevious Property Devious Auto
_SLS_InterfaceEff Property Eff Auto
_SLS_InterfaceSgo Property Sgo Auto
_SLS_InterfaceFhu Property Fhu Auto
_SLS_InterfaceAmputation Property Amp Auto
_SLS_InterfaceAproposTwo Property AproposTwo Auto
_SLS_InterfaceSlavetats Property Tats Auto
_SLS_InterfaceMilkAddict Property MilkAddict Auto
_SLS_InterfaceSlax Property Sla Auto
_SLS_InterfaceDeviousFollowers Property Dflow Auto
_SLS_InterfaceSlsf Property Slsf Auto
_SLS_InterfaceSlso Property Slso Auto
_SLS_InterfaceEatSleepDrink Property EatSleepDrink Auto
_SLS_InterfaceSpankThatAss Property Sta Auto
_SLS_InterfaceBis Property Bis Auto
_SLS_InterfaceSexyMove Property SexyMove Auto
CWScript Property Cw Auto
