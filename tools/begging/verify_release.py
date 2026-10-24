# Compares the release copy with the original record by record: only the INFOs that lost a DoM condition may differ,
# each by exactly one CTDA; no CTDA in the release may still point at master index 2 (old DoM slot).
import struct
import sys

sys.path.insert(0, r'C:\Modding\MO2\work\SLS_Repack\tools')
from seqcheck import records, subrecords  # noqa: E402


def load(p):
    d = open(p, 'rb').read()
    h = struct.unpack_from('<I', d, 4)[0]
    return {(t, fid): body for t, fl, fid, body in records(d, 24 + h, len(d))}


a, b = load(sys.argv[1]), load(sys.argv[2])
assert a.keys() == b.keys(), 'record sets differ'
changed = [k for k in a if a[k] != b[k]]
bad = []
for k in changed:
    ca = [r for t, r in subrecords(a[k]) if t == b'CTDA']
    cb = [r for t, r in subrecords(b[k]) if t == b'CTDA']
    rest_a = b''.join(r for t, r in subrecords(a[k]) if t != b'CTDA')
    rest_b = b''.join(r for t, r in subrecords(b[k]) if t != b'CTDA')
    if len(ca) - len(cb) != 1 or rest_a != rest_b:
        bad.append(k)
left = []
for k, body in b.items():
    for t, r in subrecords(body):
        if t == b'CTDA':
            p1, p2 = struct.unpack_from('<II', r, 6 + 12)
            ref = struct.unpack_from('<I', r, 6 + 24)[0] if len(r) >= 6 + 28 else 0
            if 2 in (p1 >> 24, p2 >> 24, ref >> 24) and (p1 >> 24 == 2 or ref >> 24 == 2):
                left.append(f'{k[1]:08X}')
print(len(a), 'records,', len(changed), 'changed:', [f'{k[0].decode()} {k[1]:08X}' for k in changed])
print('bad changes:', bad, ' conditions still pointing at slot 2:', left)
