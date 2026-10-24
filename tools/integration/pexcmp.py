"""Compare two .pex files by content: variables, properties and function bodies, order-insensitive."""
import io, sys, os
sys.path.insert(0, os.path.dirname(__file__))
import pexdis
def blocks(p):
    buf = io.StringIO(); pexdis.dis(p, out=buf)
    out, cur = set(), None
    for line in buf.getvalue().lower().splitlines():
        if line.startswith('  ') and not line.startswith('  var') and not line.startswith('  property') and cur is not None:
            cur.append(line); continue
        if cur is not None: out.add('\n'.join(cur)); cur = None
        if line.startswith('  var') or line.startswith('  property') or line.startswith('object'):
            out.add(line)
        else:
            cur = [line]
    if cur: out.add('\n'.join(cur))
    return out
a, b = blocks(sys.argv[1]), blocks(sys.argv[2])
only_a, only_b = a - b, b - a
print('SAME' if not only_a and not only_b else f'DIFF  only-first {len(only_a)}  only-second {len(only_b)}')
if '-v' in sys.argv:
    for x in sorted(only_a): print('--- first only:\n' + x[:600])
    for x in sorted(only_b): print('+++ second only:\n' + x[:600])
