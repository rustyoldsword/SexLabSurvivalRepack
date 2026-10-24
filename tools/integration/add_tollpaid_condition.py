# SLS-TOLL-1: the toll collector keeps offering "Why's the gate locked?" / "I can't afford the toll..." after the toll
# is paid, because only the "Pay toll" line (INFO 00AC2B) checks _SLS_Main ::IsTollPaid_var == 0. This copies that
# exact condition (CTDA + its CIS2 variable name) onto the end of the condition block of the other collector lines.
# Byte-level on purpose: a houseCARL in-place save prunes the unused DLC masters, which renumbers the plugin's own
# FormIDs (07 -> 04) and breaks the AutoSEQ .seq. Here masters, record order and everything else stay as they are.
# Run: python -I add_tollpaid_condition.py <in.esp> <out.esp>
import struct
import sys

SOURCE = 0x0700AC2B  # "Pay toll" - the line that already has the condition
TARGETS = [0x0700A0E7, 0x0701AA4B, 0x0701AA4D, 0x070A7DA2]
COND_TYPES = (b'CTDA', b'CIS1', b'CIS2')


def subrecords(body):
    i, out = 0, []
    while i < len(body):
        t = body[i:i + 4]
        n = struct.unpack_from('<H', body, i + 4)[0]
        out.append((t, body[i:i + 6 + n]))
        i += 6 + n
    return out


def conditions(subs):
    # list of (CTDA bytes + following CIS1/CIS2 bytes)
    out = []
    for t, raw in subs:
        if t == b'CTDA':
            out.append(raw)
        elif t in (b'CIS1', b'CIS2'):
            out[-1] += raw
    return out


def find_records(data):
    # (offset, formid) of every record, plus the chain of enclosing GRUP offsets
    recs = {}

    def walk(start, end, parents):
        i = start
        while i < end:
            t = data[i:i + 4]
            size = struct.unpack_from('<I', data, i + 4)[0]
            if t == b'GRUP':
                walk(i + 24, i + size, parents + [i])
                i += size
            else:
                fid = struct.unpack_from('<I', data, i + 12)[0]
                recs[fid] = (i, parents)
                i += 24 + size
    first = 24 + struct.unpack_from('<I', data, 4)[0]  # skip TES4
    walk(first, len(data), [])
    return recs


def main():
    src, dst = sys.argv[1], sys.argv[2]
    data = bytearray(open(src, 'rb').read())
    recs = find_records(data)

    def body(fid):
        off, _ = recs[fid]
        flags, size = struct.unpack_from('<I', data, off + 8)[0], struct.unpack_from('<I', data, off + 4)[0]
        if flags & 0x40000:
            sys.exit(f'{fid:08X} is compressed')
        return off, bytes(data[off + 24:off + 24 + size])

    _, sbody = body(SOURCE)
    want = [c for c in conditions(subrecords(sbody)) if b'::IsTollPaid_var' in c]
    if len(want) != 1:
        sys.exit('source condition not found exactly once')
    cond = want[0]
    # the copy must stay ANDed with the target's other conditions (low bit of the CTDA operator byte = OR)
    if cond[6] & 0x01:
        sys.exit('source condition carries the OR flag')

    # edit from the end of the file backwards so earlier offsets stay valid
    for fid in sorted(TARGETS, key=lambda f: recs[f][0], reverse=True):
        off, b = body(fid)
        subs = subrecords(b)
        if any(cond == c for c in conditions(subs)):
            print(f'{fid:08X}: already has the condition')
            continue
        last = max(i for i, (t, _) in enumerate(subs) if t in COND_TYPES)
        pos = off + 24 + sum(len(r) for _, r in subs[:last + 1])
        data[pos:pos] = cond
        grow = len(cond)
        struct.pack_into('<I', data, off + 4, struct.unpack_from('<I', data, off + 4)[0] + grow)
        for g in recs[fid][1]:
            struct.pack_into('<I', data, g + 4, struct.unpack_from('<I', data, g + 4)[0] + grow)
        print(f'{fid:08X}: +{grow} bytes, now {len(conditions(subrecords(body(fid)[1])))} conditions')
        recs = find_records(data)
    open(dst, 'wb').write(data)


if __name__ == '__main__':
    main()
