# Compares a plugin's Start Game Enabled quests with a .seq file (array of uint32 FormIDs, load-order-relative).
#   python seqcheck.py <plugin.esp> [<file.seq>]  -> lists SGE quests and the diff against the .seq
import struct
import sys
import zlib


def records(data, start, end):
    i = start
    while i < end:
        typ, size = data[i:i + 4], struct.unpack_from('<I', data, i + 4)[0]
        if typ == b'GRUP':
            yield from records(data, i + 24, i + size)
            i += size
        else:
            flags, fid = struct.unpack_from('<II', data, i + 8)
            yield typ, flags, fid, data[i + 24:i + 24 + size]
            i += 24 + size


def subrecords(body):
    i = 0
    while i + 6 <= len(body):
        t, n = body[i:i + 4], struct.unpack_from('<H', body, i + 4)[0]
        yield t, body[i + 6:i + 6 + n]
        i += 6 + n


def sge_quests(path):
    data = open(path, 'rb').read()
    hdr = struct.unpack_from('<I', data, 4)[0]
    out = []
    for typ, flags, fid, body in records(data, 24 + hdr, len(data)):
        if typ != b'QUST':
            continue
        if flags & 0x40000:
            body = zlib.decompress(body[4:])
        for t, v in subrecords(body):
            if t == b'DNAM' and struct.unpack_from('<H', v, 0)[0] & 0x1:  # Start Game Enabled
                out.append(fid)
                break
    return out


def main():
    q = sge_quests(sys.argv[1])
    print(len(q), 'start-game-enabled quests')
    if len(sys.argv) > 2:
        b = open(sys.argv[2], 'rb').read()
        s = list(struct.unpack(f'<{len(b) // 4}I', b))
        print(len(s), 'in .seq;  missing from .seq:', [f'{x:08X}' for x in q if x not in s],
              ' extra in .seq:', [f'{x:08X}' for x in s if x not in q])


if __name__ == '__main__':
    main()
