# Release copy of SLS Begging Conditions.esp without the Diary of Mine master (the owner's own copy keeps it).
# Byte level, no renumbering: every CTDA condition whose parameter points into DiaryOfMine.esm is dropped, and the
# master entry DiaryOfMine.esm is renamed to Dawnguard.esm (always present, and Skyrim < Update < Dawnguard <
# Devious Devices - Assets < SL Survival is a valid load order), so no FormID index moves.
#   python release_no_dom.py <in.esp> <out.esp>
import struct
import sys

DOM, REPLACEMENT = b'DiaryOfMine.esm', b'Dawnguard.esm'


def subrecords(body):
    i = 0
    while i + 6 <= len(body):
        t, n = body[i:i + 4], struct.unpack_from('<H', body, i + 4)[0]
        yield t, body[i:i + 6 + n]
        i += 6 + n


def main():
    data = bytearray(open(sys.argv[1], 'rb').read())
    hsize = struct.unpack_from('<I', data, 4)[0]
    header = bytes(data[24:24 + hsize])
    masters, out_hdr = [], b''
    for t, raw in subrecords(header):
        if t == b'MAST':
            name = raw[6:-1]
            masters.append(name)
            if name == DOM:
                raw = b'MAST' + struct.pack('<H', len(REPLACEMENT) + 1) + REPLACEMENT + b'\0'
        out_hdr += raw
    if DOM not in masters or REPLACEMENT in masters:
        sys.exit(f'unexpected masters: {masters}')
    dom = masters.index(DOM)
    tes4 = bytes(data[:4]) + struct.pack('<I', len(out_hdr)) + bytes(data[8:24]) + out_hdr
    removed = []

    def walk(buf):
        # returns the rewritten buffer of a sequence of records/groups
        out, i = b'', 0
        while i < len(buf):
            typ, size = buf[i:i + 4], struct.unpack_from('<I', buf, i + 4)[0]
            if typ == b'GRUP':
                inner = walk(buf[i + 24:i + size])
                out += buf[i:i + 4] + struct.pack('<I', 24 + len(inner)) + buf[i + 8:i + 24] + inner
                i += size
                continue
            flags, fid = struct.unpack_from('<II', buf, i + 8)
            body = buf[i + 24:i + 24 + size]
            if typ == b'INFO' and not flags & 0x40000:
                nb = b''
                for t, raw in subrecords(body):
                    if t == b'CTDA':
                        p1 = struct.unpack_from('<I', raw, 6 + 12)[0]
                        if p1 >> 24 == dom:
                            removed.append(f'{fid:08X} param {p1:08X}')
                            continue
                    nb += raw
                body = nb
            out += buf[i:i + 4] + struct.pack('<I', len(body)) + buf[i + 8:i + 24] + body
            i += 24 + size
        return out

    rest = walk(bytes(data[24 + hsize:]))
    blob = tes4 + rest
    if DOM in blob:
        sys.exit('DiaryOfMine.esm still named in the file')
    # nothing else may still point into the old DoM slot (CTDA reference fields, other links): report any 4-byte hit
    open(sys.argv[2], 'wb').write(blob)
    print(f'masters {[m.decode() for m in masters]} -> {DOM.decode()} replaced by {REPLACEMENT.decode()}')
    print(len(removed), 'conditions removed:', *removed, sep='\n  ')


if __name__ == '__main__':
    main()
