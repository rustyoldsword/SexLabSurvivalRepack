# minimal Papyrus pex disassembler: signatures + instruction listing
import struct,sys
OPS={0:('nop',0),1:('iadd',3),2:('fadd',3),3:('isub',3),4:('fsub',3),5:('imul',3),6:('fmul',3),7:('idiv',3),8:('fdiv',3),9:('imod',3),
0xA:('not',2),0xB:('ineg',2),0xC:('fneg',2),0xD:('assign',2),0xE:('cast',2),0xF:('cmp_eq',3),0x10:('cmp_lt',3),0x11:('cmp_le',3),0x12:('cmp_gt',3),0x13:('cmp_ge',3),
0x14:('jmp',1),0x15:('jmpt',2),0x16:('jmpf',2),0x17:('callmethod',3),0x18:('callparent',2),0x19:('callstatic',3),0x1A:('return',1),0x1B:('strcat',3),
0x1C:('propget',3),0x1D:('propset',3),0x1E:('array_create',2),0x1F:('array_length',2),0x20:('array_getelement',3),0x21:('array_setelement',3),0x22:('array_findelement',4),0x23:('array_rfindelement',4),
0x24:('is',3),0x25:('struct_create',1),0x26:('struct_get',3),0x27:('struct_set',3),0x28:('array_findstruct',5),0x29:('array_rfindstruct',5)}
class R:
    def __init__(s,b): s.b=b; s.p=0
    def u8(s): v=s.b[s.p]; s.p+=1; return v
    def u16(s): v=struct.unpack_from('>H',s.b,s.p)[0]; s.p+=2; return v
    def u32(s): v=struct.unpack_from('>I',s.b,s.p)[0]; s.p+=4; return v
    def ws(s): n=s.u16(); v=s.b[s.p:s.p+n].decode('latin-1'); s.p+=n; return v
def dis(path,out=sys.stdout,only=None):
    r=R(open(path,'rb').read()); assert r.u32()==0xFA57C0DE
    r.u8();r.u8();r.u16();r.p+=8; r.ws();r.ws();r.ws()
    S=[r.ws() for _ in range(r.u16())]
    if r.u8():
        r.p+=8
        for _ in range(r.u16()):
            r.u16();r.u16();r.u16();r.u8(); n=r.u16(); r.p+=2*n
    for _ in range(r.u16()): r.u16(); r.u8()
    def val():
        t=r.u8()
        if t==0: return 'None'
        if t==1: return S[r.u16()]
        if t==2: return repr(S[r.u16()])
        if t==3: v=struct.unpack_from('>i',r.b,r.p)[0]; r.p+=4; return str(v)
        if t==4: v=struct.unpack_from('>f',r.b,r.p)[0]; r.p+=4; return repr(round(v,4))
        if t==5: return 'True' if r.u8() else 'False'
    def func(name,st):
        rt=S[r.u16()]; doc=S[r.u16()]; r.u32(); fl=r.u8()
        ps=[(S[r.u16()],S[r.u16()]) for _ in range(r.u16())]
        ls=[(S[r.u16()],S[r.u16()]) for _ in range(r.u16())]
        sig=f"{rt} {name}({', '.join(t+' '+n for n,t in ps)}){' global' if fl&1 else ''}{' native' if fl&2 else ''}  [state {st or 'default'}]"
        lines=[]
        for i in range(r.u16()):
            op=r.u8(); nm,n=OPS[op]; a=[val() for _ in range(n)]
            if op in(0x17,0x18,0x19):
                c=r.u8(); cnt=struct.unpack_from('>i',r.b,r.p)[0]; r.p+=4
                a+=[val() for _ in range(cnt)]
            lines.append(f"  {i:4} {nm} {', '.join(a)}")
        if only is None or any(o.lower()==name.lower() for o in only):
            print(sig,file=out)
            if only is not None or True: print('\n'.join(lines),file=out)
    for _ in range(r.u16()):
        on=S[r.u16()]; sz=r.u32(); parent=S[r.u16()]; r.u16(); r.u32(); autost=S[r.u16()]
        print(f"OBJECT {on} extends {parent}",file=out)
        for _ in range(r.u16()):
            vn=S[r.u16()]; vt=S[r.u16()]; r.u32(); v=val(); print(f"  var {vt} {vn} = {v}",file=out)
        for _ in range(r.u16()):
            pn=S[r.u16()]; pt=S[r.u16()]; r.u16(); r.u32(); fl=r.u8()
            if fl&4: av=S[r.u16()]; print(f"  property {pt} {pn} auto -> {av}",file=out)
            else:
                print(f"  property {pt} {pn}",file=out)
                if fl&1: func(pn+'.get','prop')
                if fl&2: func(pn+'.set','prop')
        for _ in range(r.u16()):
            st=S[r.u16()]
            for _ in range(r.u16()):
                fn=S[r.u16()]; func(fn,st)
if __name__=='__main__':
    only=sys.argv[2:] or None
    dis(sys.argv[1],only=only)
