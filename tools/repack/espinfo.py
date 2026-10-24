# form-version histogram, masters, SGE quests of a plugin
import struct, sys, collections, zlib
b = open(sys.argv[1], 'rb').read()
fv = collections.Counter(); sge = []
hs = struct.unpack_from('<I', b, 4)[0]
masters=[]; p=24
while p < 24+hs:
    sig=b[p:p+4]; n=struct.unpack_from('<H',b,p+4)[0]
    if sig==b'MAST': masters.append(b[p+6:p+6+n-1].decode())
    p+=6+n
print('TES4 form', struct.unpack_from('<H', b, 20)[0], 'flags %08X' % struct.unpack_from('<I', b, 8)[0], 'masters', masters)
def walk(q, end):
    while q < end:
        sig = b[q:q+4]; size = struct.unpack_from('<I', b, q+4)[0]
        if sig == b'GRUP': walk(q+24, q+size); q += size; continue
        flags, fid = struct.unpack_from('<II', b, q+8); ver = struct.unpack_from('<H', b, q+20)[0]
        fv[ver] += 1
        if sig == b'QUST':
            data = b[q+24:q+24+size]
            if flags & 0x40000: data = zlib.decompress(data[4:])
            r = 0
            while r < len(data):
                s = data[r:r+4]; n = struct.unpack_from('<H', data, r+4)[0]
                if s == b'DNAM':
                    qf = struct.unpack_from('<H', data, r+6)[0]
                    if qf & 1: sge.append((fid, qf))
                    break
                r += 6 + n
        q += 24 + size
walk(24+hs, len(b))
print('form versions', dict(fv))
print('SGE quests', len(sge), ' '.join('%08X' % f for f, _ in sge))
