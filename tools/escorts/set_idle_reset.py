"""Escort idle chatter: set ENAM reset hours on every INFO whose VMAD carries _SLSHE_TIF_IdleNext, so a line
just spoken stays unavailable for N game hours (vanilla's own anti-repeat, as on Random Hit lines). In-place
byte edit: no size change, FormIDs/masters untouched. Run: python -I set_idle_reset.py <esp> [hours]"""
import struct, sys
p = sys.argv[1]; hours = float(sys.argv[2]) if len(sys.argv) > 2 else 2.0
raw = round(hours * 65535 / 24)
b = bytearray(open(p, 'rb').read())
hits = []
def walk(s, e):
    i = s
    while i < e:
        sig = bytes(b[i:i+4]); size = struct.unpack_from('<I', b, i+4)[0]
        if sig == b'GRUP':
            walk(i+24, i+size); i += size; continue
        flags = struct.unpack_from('<I', b, i+8)[0]
        if sig == b'INFO':
            assert not flags & 0x40000, 'compressed INFO'
            j, end = i+24, i+24+size; enam = None; idle = False
            while j < end:
                ss = bytes(b[j:j+4]); sz = struct.unpack_from('<H', b, j+4)[0]
                if ss == b'ENAM': enam = j+6
                if ss == b'VMAD' and b'_SLSHE_TIF_IdleNext' in b[j+6:j+6+sz]: idle = True
                j += 6+sz
            if idle:
                assert enam is not None
                hits.append(struct.unpack_from('<I', b, i+12)[0])
                struct.pack_into('<H', b, enam+2, raw)
        i += 24+size
first = 24 + struct.unpack_from('<I', b, 4)[0]
walk(first, len(b))
open(p, 'wb').write(b)
print('INFOs', len(hits), 'reset raw', raw, '=', raw*24/65535, 'h')
