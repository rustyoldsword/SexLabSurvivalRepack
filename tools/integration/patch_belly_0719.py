"""Port of crajjjj/SLSurvival 0.718 belly changes into our src/ (2026-10-12).

- _sls_needs: the -1.0 "stage is being swapped, ask again" sentinel of the needs adapters is passed through
  instead of being added to BaseBellyScale (upstream fix for Rnd/iNeed/Esd; applied to our Shs state too).
- _sls_needs State Ccs (ours): belly grows only on the fullest stage (Well Fed), +0.3, like upstream 0.718.
- _SLS_InterfaceShs: 0.718 defaults (0.3 on Well Fed, 0 elsewhere).
- sls_mcm: slider defaults and Settings.json fallbacks for RND/iNeed match the new property defaults;
  Belly Scaling switch is no longer greyed out for EatingSleepingDrinking / SunHelm / CC Survival.
Idempotent: run after tools\\patch_needs.py etc. regenerate src\\.
"""
import pathlib, re, sys

SRC = pathlib.Path(__file__).resolve().parent.parent / 'src'


def edit(name, pairs):
    p = SRC / name
    t = p.read_text(encoding='utf-8-sig')
    for old, new in pairs:
        if new in t:
            continue
        n = t.count(old)
        if n != 1:
            sys.exit(f'{name}: expected 1 match, found {n}: {old[:70]!r}')
        t = t.replace(old, new)
    p.write_text(t, encoding='utf-8')
    print('ok', name)


SENTINEL = '''	Float Function GetBellyScale()
		; -1.0 is the adapter's "stage is being swapped, ask again" sentinel (crajjjj 0.718). Adding the
		; base to it hides it from the gluttony script's retry test, and the belly snaps flat mid-swap.
		Float Raw = {obj}.GetBellyScale()
		If Raw == -1.0
			Return -1.0
		EndIf
		Return BaseBellyScale + Raw
	EndFunction'''

edit('_sls_needs.psc', [
    ('''	Float Function GetBellyScale()
		Return BaseBellyScale + %s.GetBellyScale()
	EndFunction''' % o, SENTINEL.format(obj=o)) for o in ('Rnd', 'Ineed', 'EatSleepDrink', 'Shs')
] + [(
    '		Return BaseBellyScale + 1.5 - (Stage * 0.3) ; 1.5 well fed .. 0.0 ravenous: the SunHelm adapter\'s ladder',
    '''		; crajjjj 0.718: only the fullest stomach shows, and only a little - an ordinary hunger level
		; leaves the belly alone. Stage 0 = Well Fed, Survival Mode's counterpart of RND's Glutted.
		If Stage == 0
			Return BaseBellyScale + 0.3
		EndIf
		Return BaseBellyScale''',
)])

edit('_SLS_InterfaceShs.psc', [(
    '''; Belly scale values
Float Property BellyScaleShs00 = 1.5 Auto Hidden
Float Property BellyScaleShs01 = 1.2 Auto Hidden
Float Property BellyScaleShs02 = 0.9 Auto Hidden
Float Property BellyScaleShs03 = 0.6 Auto Hidden
Float Property BellyScaleShs04 = 0.3 Auto Hidden''',
    '''; Belly scale values, added to the base belly scale (crajjjj 0.718). By default only overeating
; (Well Fed) shows, and only a little: an ordinary hunger level leaves the belly alone.
Float Property BellyScaleShs00 = 0.3 Auto Hidden
Float Property BellyScaleShs01 = 0.0 Auto Hidden
Float Property BellyScaleShs02 = 0.0 Auto Hidden
Float Property BellyScaleShs03 = 0.0 Auto Hidden
Float Property BellyScaleShs04 = 0.0 Auto Hidden''',
)])

mcm = [(
    '''		If RndFlag == OPTION_FLAG_NONE || IneedFlag == OPTION_FLAG_NONE
			BellyNeedsMod = OPTION_FLAG_NONE
		EndIf''',
    '''		; Every needs mod _SLS_Needs drives a belly for, so each gets the switch that turns it off
		; (crajjjj 0.717 for ESD/SunHelm; Survival Mode is ours - an ESL, so by form, not GetModByName).
		If RndFlag == OPTION_FLAG_NONE || IneedFlag == OPTION_FLAG_NONE || EatingSleepingDrinkingFlag == OPTION_FLAG_NONE || Game.GetModByName("SunHelmSurvival.esp") != 255 || Game.GetFormFromFile(0x000826, "ccqdrsse001-survivalmode.esl")
			BellyNeedsMod = OPTION_FLAG_NONE
		EndIf''',
)]
for i, (old, new) in enumerate([('2.5', '0.3'), ('1.4', '0.0'), ('1.3', '0.0'), ('1.2', '0.0'), ('1.1', '0.0'), ('1.0', '0.0')]):
    mcm.append((f'SetSliderOptions(Value = Rnd.BellyScaleRnd0{i}, Default = {old},', f'SetSliderOptions(Value = Rnd.BellyScaleRnd0{i}, Default = {new},'))
for i, (old, new) in enumerate([('0.9', '0.3'), ('0.6', '0.0'), ('0.3', '0.0')]):
    mcm.append((f'SetSliderOptions(Value = Ineed.BellyScaleIneed0{i}, Default = {old},', f'SetSliderOptions(Value = Ineed.BellyScaleIneed0{i}, Default = {new},'))
for i, (old, new) in enumerate([('1.5', '0.3'), ('0.4', '0.0'), ('0.3', '0.0'), ('0.2', '0.0'), ('0.1', '0.0')]):
    mcm.append((f'"Rnd.BellyScaleRnd0{i}", missing = {old})', f'"Rnd.BellyScaleRnd0{i}", missing = {new})'))
for i, (old, new) in enumerate([('0.9', '0.3'), ('0.6', '0.0'), ('0.3', '0.0')]):
    mcm.append((f'"Ineed.BellyScaleIneed0{i}", missing = {old})', f'"Ineed.BellyScaleIneed0{i}", missing = {new})'))
edit('sls_mcm.psc', mcm)
