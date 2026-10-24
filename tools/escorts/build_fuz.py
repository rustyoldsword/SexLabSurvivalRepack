# Turns the voiced WAVs (tts\out_fish\<ID>.wav) into game voice files for SL Survival - Hopeless Escorts Dialogue.esp:
#   .lip  - Creation Kit LipGenerator (text from the voice script)
#   .xwm  - xWMAEncode
#   .fuz  - "FUZE", version 1, lip size, lip, xwm
# named Sound\Voice\<plugin>\<VoiceType>\<quest>_<topic>_<00 + INFO local FormID>_1.fuz.
# Run: python -I build_fuz.py [--only HE_MIL_HELLO_01 ...]   (rebuilds every line that has a WAV)
import argparse
import csv
import json
import os
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
PLUGIN = 'SL Survival - Hopeless Escorts Dialogue.esp'
QUEST = '_SLSHE_Dlg'
MOD = r'C:\Modding\MO2\mods\SL Survival - Patches'
LIPGEN = r'C:\Modding\MO2\basegame\Tools\LipGen\LipGenerator\LipGenerator.exe'
XWMA = r'C:\Modding\MO2\basegame\Tools\LipGen\LipGenerator\xWMAEncode.exe'
WAVS = os.path.join(HERE, 'tts', 'out_fish')  # Fish Audio voice pack (2026-10-21); tts\out = first ElevenLabs take
# the game voice type each escort speaks with (folder name); see lines.py CHARACTERS
VOICE = {'MIL': 'MaleDrunk', 'BEG': 'MaleDrunk', 'SCR': 'MaleYoungEager', 'FRM': 'MaleNord',
         'REC': 'MaleYoungEager', 'WAT': 'MaleEvenToned'}


# Topic FormIDs in the plugin. gen_plugin.py creates each topic and then its lines, so a line belongs to the
# topic with the highest FormID below its own (the off-order dump does not carry the owning topic).
TOPICS = [(0x802, '_SLSHE_Idle'), (0x8E6, '_SLSHE_Combat'), (0x8F9, '_SLSHE_Win'), (0x90C, '_SLSHE_Intro'),
          (0x91F, '_SLSHE_Talk1'), (0x927, '_SLSHE_Talk2'), (0x92F, '_SLSHE_Talk3'), (0x937, '_SLSHE_Talk4')]


def infos():
    # INFO EditorID _SLSHE_<line ID> -> (topic EditorID, local FormID), read from a houseCARL dump of the plugin
    out = {}
    with open(os.path.join(HERE, 'infos_formids.jsonl'), encoding='utf-8') as f:
        for n, line in enumerate(f):
            if n == 0:
                continue
            r = json.loads(line)
            local = int(r['formid'].split(':')[0], 16)
            topic = [name for fid, name in TOPICS if fid < local][-1]
            out[r['editorid'][len('_SLSHE_'):]] = (topic, local)
    return out


def texts():
    with open(os.path.join(HERE, 'ESCORT_VOICE_SCRIPT.csv'), encoding='utf-8-sig', newline='') as f:
        return {r[0]: r[5] for r in list(csv.reader(f))[1:]}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--only', nargs='*')
    args = ap.parse_args()
    ids, text = infos(), texts()
    missing_info = [i for i in text if i not in ids]
    if missing_info:
        sys.exit(f'lines without an INFO in the plugin: {missing_info[:5]}')
    built, no_wav, failed = 0, [], []
    with tempfile.TemporaryDirectory() as tmp:
        for rid in text:
            if args.only and rid not in args.only:
                continue
            wav = os.path.join(WAVS, rid + '.wav')
            if not os.path.exists(wav):
                no_wav.append(rid)
                continue
            topic, local = ids[rid]
            folder = os.path.join(MOD, 'Sound', 'Voice', PLUGIN, VOICE[rid.split('_')[1]])
            name = f'{QUEST}_{topic}_{local & 0xFFFFFF:08X}_1'.lower()  # high byte always 00 (local FormID)
            tw, tl, tx = (os.path.join(tmp, rid + e) for e in ('.wav', '.lip', '.xwm'))
            shutil.copyfile(wav, tw)
            subprocess.run([LIPGEN, tw, text[rid], '-Language:USEnglish', '-Automated'], cwd=os.path.dirname(LIPGEN),
                           capture_output=True)
            subprocess.run([XWMA, '-b', '48000', tw, tx], capture_output=True)
            if not (os.path.exists(tl) and os.path.getsize(tl) > 0 and os.path.exists(tx)):
                failed.append(rid)
                continue
            lip, xwm = open(tl, 'rb').read(), open(tx, 'rb').read()
            os.makedirs(folder, exist_ok=True)
            with open(os.path.join(folder, name + '.fuz'), 'wb') as f:
                f.write(b'FUZE' + struct.pack('<II', 1, len(lip)) + lip + xwm)
            built += 1
    print(f'{built} .fuz built, {len(no_wav)} lines without a WAV yet, {len(failed)} failed')
    if failed:
        print('failed:', ' '.join(failed))
    if no_wav and len(no_wav) <= 20:
        print('no WAV:', ' '.join(no_wav))


if __name__ == '__main__':
    main()
