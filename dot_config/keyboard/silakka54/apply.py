# Writes the silakka54 keymap over Vial raw HID. Quit Vial first: it locks the device.
# Keycodes target a macOS Spanish-ISO host. RALT, not LALT: Ghostty treats left Option as Meta.
from vialio import *
T,N=1,0
def S(k): return 0x0200|k
def RA(k): return 0x1400|k
def CA(k): return 0x0500|k
C_A,CTL_ESC=0x0104,0x2129
LO,RS,AE=0x5221,0x5222,0x5223
BSP,SPC,ENT,TAB,CMD,LALT,LSFT,RSFT=0x2a,0x2c,0x28,0x2b,0xe3,0xe2,0xe1,0xe5
A=lambda s:[4+ord(c)-97 for c in s]            # letters
N1,N2,N3,N4,N5,N6,N7,N8,N9,N0=range(0x1e,0x28)
QUO,GRV_D,PLUS,CC,NTIL,ACUT,LT,COM,DOT,DASH=0x2d,0x2f,0x30,0x31,0x33,0x34,0x35,0x36,0x37,0x38
# Each layer: rows of (left six, right six) in visual order, then (left three, right three) thumbs.
BASE=[([C_A,N1,N2,N3,N4,N5],[N6,N7,N8,N9,N0,BSP]),
      ([TAB,*A('qwert')],[*A('yuiop'),QUO]),
      ([CTL_ESC,*A('asdfg')],[*A('hjkl'),NTIL,LALT]),
      ([LSFT,*A('zxcvb')],[*A('nm'),COM,DOT,DASH,RSFT]),
      ([AE,LO,SPC],[ENT,RS,CMD])]
LOWER=[([T,*range(0x3a,0x3f)],[*range(0x3f,0x44),0x44,0x45][:5]+[0x4c]),  # F-row, Bksp -> Del
       ([T]*6,[0x4a,0x4e,0x4b,0x4d,T,T]),
       ([T]*6,[0x50,0x51,0x52,0x4f,T,T]),
       ([T]*6,[0xa8,0xaa,0xa9,0xae,T,T]),
       ([T,T,T],[T,T,T])]
RAISE=[([T]*6,[T]*6),
       ([T,S(N1),RA(N2),RA(N3),S(N4),S(N5)],[S(GRV_D),S(N6),S(PLUS),S(QUO),S(N7),RA(0x64)]),
       ([T,S(N0),PLUS,DASH,S(DASH),RA(N1)],[S(N2),S(N8),S(N9),RA(ACUT),RA(CC),ACUT]),
       ([T,LT,S(LT),S(COM),S(DOT),RA(NTIL)],[GRV_D,RA(GRV_D),RA(PLUS),T,T,T]),
       ([T,T,T],[T,T,T])]
a=A('abcdefghijklmnopqrstuvwxyz'); ca=lambda c:CA(a[ord(c)-97])
AERO=[([N,*[CA(n) for n in (N1,N2,N3,N4,N5)]],[*[CA(n) for n in (N6,N7,N8,N9)],N,N]),
      ([CA(TAB),ca('q'),ca('w'),N,ca('r'),N],[N,N,N,CA(0x2d),CA(0x2e),N]),
      ([T,N,N,N,ca('f'),N],[ca('h'),ca('j'),ca('k'),ca('l'),CA(0x33),N]),
      ([T,N,N,ca('c'),N,ca('b')],[N,N,CA(COM),N,CA(DASH),T]),
      ([T,N,N],[CA(ENT),N,N])]
LAYERS=[BASE,LOWER,RAISE,AERO]
def pos(ly):
    o={}
    for r,(l,rr) in enumerate(ly[:4]):
        assert len(l)==len(rr)==6
        for c in range(6): o[(r,c)]=l[c]; o[(r+5,c)]=rr[5-c]   # right half is mirrored in the matrix
    (l,rr)=ly[4]
    for i in range(3): o[(4,3+i)]=l[i]; o[(9,5-i)]=rr[i]
    assert len(o)==54; return o
k=KB()
for n,ly in enumerate(LAYERS):
    for (r,c),v in pos(ly).items(): k.x(5,n,r,c,v>>8,v&255)
for n,ly in enumerate(LAYERS):
    for (r,c),v in pos(ly).items():
        got=int.from_bytes(k.x(4,n,r,c)[4:6],'big'); assert got==v,(n,r,c,hex(got),hex(v))
assert k.x(0xFE,0x0B,8,0,1)[0]==0                  # Permissive Hold: fast Ctrl chords on the Esc key
assert k.x(0xFE,0x0A,8,0)[1]==1
print('ok: 4 layers written and read back, permissive hold on')
