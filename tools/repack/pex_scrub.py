# Rewrite the identity strings of a compiled Papyrus .pex header: source path -> bare file name,
# user and machine -> a neutral name. Everything after the header is copied byte for byte (nothing in a pex
# refers to absolute offsets). usage: pex_scrub.py <file.pex> [...]   (in place; prints what changed)
import struct, sys, os

NEUTRAL = b'SLSRepack'  # never the publishing pseudonym (owner rule 2026-10-13)

def ws(b, p):
    n = struct.unpack_from('>H', b, p)[0]
    return b[p + 2:p + 2 + n], p + 2 + n

def pack(s): return struct.pack('>H', len(s)) + s

def scrub(path):
    b = open(path, 'rb').read()
    if struct.unpack_from('>I', b, 0)[0] != 0xFA57C0DE: raise ValueError(path + ': not a pex')
    p = 16
    src, p1 = ws(b, p); user, p2 = ws(b, p1); mach, p3 = ws(b, p2)
    name = src.replace(b'/', b'\\').rsplit(b'\\', 1)[-1]
    new = b[:16] + pack(name) + pack(NEUTRAL) + pack(NEUTRAL) + b[p3:]
    if new != b:
        open(path, 'wb').write(new)
        return f'{os.path.basename(path)}: {src.decode("latin-1")} | {user.decode("latin-1")} | {mach.decode("latin-1")}'
    return None

if __name__ == '__main__':
    n = 0
    for f in sys.argv[1:]:
        r = scrub(f)
        if r: n += 1
    print(f'scrubbed {n} of {len(sys.argv) - 1}')
