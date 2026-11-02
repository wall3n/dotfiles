import hid, struct, json, lzma
class KB:
    def __init__(s):
        p=[d for d in hid.enumerate() if d['usage_page']==0xFF60 and d['usage']==0x61 and d['product_string']=='silakka54']
        assert p,'no raw hid'
        s.d=hid.device(); s.d.open_path(p[0]['path'])
    def x(s,*b):
        m=bytes(b).ljust(32,b'\0'); s.d.write(b'\0'+m)
        r=bytes(s.d.read(32,2000)); assert len(r)==32,'timeout'; return r
    def definition(s):
        n=struct.unpack('<I',s.x(0xFE,1)[:4])[0]; o=b''
        for p in range(n//32+1): o+=s.x(0xFE,2,p&255,p>>8)
        return json.loads(lzma.decompress(o[:n]))
