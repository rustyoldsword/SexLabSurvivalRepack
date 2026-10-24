# Drop whole records from a plugin by byte surgery (no re-serialization of anything else).
# usage: clean_esp.py <in.esp> <out.esp> <ids.txt>   ids: 'XXXXXX:Plugin.esm' per line
# Removes each record, the cell-children GRUP of a removed CELL, and every GRUP left empty;
# fixes enclosing GRUP sizes and the TES4 HEDR record count.
import struct, sys

def main():
    src, dst, idfile = sys.argv[1:4]
    b = bytes(open(src, 'rb').read())
    assert b[:4] == b'TES4'
    hsize = struct.unpack_from('<I', b, 4)[0]
    # masters
    masters = []; p = 24
    while p < 24 + hsize:
        sig = b[p:p + 4]; n = struct.unpack_from('<H', b, p + 4)[0]
        if sig == b'MAST': masters.append(b[p + 6:p + 6 + n - 1].decode('latin-1').lower())
        p += 6 + n
    self_idx = len(masters)
    want = set()
    for line in open(idfile):
        line = line.strip()
        if not line: continue
        h, plug = line.split(':', 1)
        plug = plug.lower()
        idx = masters.index(plug) if plug in masters else self_idx
        want.add((idx << 24) | int(h, 16))
    found = set(); dropped = [0, 0]  # records, groups

    def rec_fid(q): return struct.unpack_from('<I', b, q + 12)[0]

    def mark(q, end):
        while q < end:
            size = struct.unpack_from('<I', b, q + 4)[0]
            if b[q:q + 4] == b'GRUP': mark(q + 24, q + size); q += size
            else:
                fid = rec_fid(q)
                if fid in want: found.add(fid); dropped[0] += 1
                q += 24 + size

    def walk(q, end):
        """returns list of byte chunks for [q,end)"""
        out = []
        last_dropped_cell = None
        while q < end:
            sig = b[q:q + 4]; size = struct.unpack_from('<I', b, q + 4)[0]
            if sig == b'GRUP':
                gtype = struct.unpack_from('<I', b, q + 12)[0]
                label = struct.unpack_from('<I', b, q + 8)[0]
                if gtype in (6, 8, 9) and label in want:      # children of a dropped CELL / DIAL
                    mark(q + 24, q + size)                      # listed children go with it
                    dropped[1] += 1; q += size; continue
                inner = walk(q + 24, q + size)
                body = b''.join(inner)
                if body:
                    hdr = bytearray(b[q:q + 24]); struct.pack_into('<I', hdr, 4, 24 + len(body))
                    out.append(bytes(hdr) + body)
                else:                                           # nothing left inside: drop the group itself
                    dropped[1] += 1
                q += size
            else:
                fid = rec_fid(q)
                if fid in want and sig != b'TES4':
                    found.add(fid); dropped[0] += 1
                else:
                    out.append(b[q:q + 24 + size])
                q += 24 + size
        return out

    head = b[:24 + hsize]
    body = b''.join(walk(24 + hsize, len(b)))
    missing = want - found
    if missing:
        sys.exit('not found in plugin: ' + ', '.join('%08X' % m for m in sorted(missing)))
    head = bytearray(head)
    p = 24
    assert head[p:p + 4] == b'HEDR'
    nrec = struct.unpack_from('<I', head, p + 10)[0]
    count = [0]
    def recount(q, end):
        while q < end:
            size = struct.unpack_from('<I', body, q + 4)[0]
            count[0] += 1
            if body[q:q + 4] == b'GRUP': recount(q + 24, q + size); q += size
            else: q += 24 + size
    recount(0, len(body))
    struct.pack_into('<I', head, p + 10, count[0])  # records + groups, TES4 excluded
    open(dst, 'wb').write(bytes(head) + body)
    print(f'dropped {dropped[0]} records; HEDR count {nrec} -> {count[0]}')

if __name__ == '__main__':
    main()
