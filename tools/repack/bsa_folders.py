# count files per folder in a BSA v104/105 (names from the folder/file name blocks)
import struct, sys, collections
for path in sys.argv[1:]:
    f = open(path, 'rb'); h = f.read(36)
    magic, ver, off, flags, nfold, nfile, lfold, lfile, ftypes = struct.unpack('<4sIIIIIIIH', h[:34])
    f.seek(off); recsz = 24 if ver == 105 else 16
    folders = [struct.unpack('<QII', f.read(16))[1:2][0] if ver != 105 else struct.unpack('<QIIQ', f.read(24))[1] for _ in range(nfold)]
    c = collections.Counter(); tot = 0
    for n in folders:
        ln = f.read(1)[0]; name = f.read(ln)[:-1].decode('latin-1')
        f.seek(16 * n, 1); c[name.split(chr(92))[-1]] += n; tot += n
    print(path.split(chr(92))[-1], 'files', nfile, 'folders', nfold)
    for k, v in c.most_common(): print(f'  {v:6} {k}')
