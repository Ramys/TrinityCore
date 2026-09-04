import struct
def dump_spell_effect(spell_id):
    path=r"c:\Users\Admin\Desktop\TrinityCore\dbc\enUS\SpellEffect.dbc"
    with open(path,'rb') as f:
        magic,rec,fields,recSize,strSize=struct.unpack('<4sIIII',f.read(20))
        print(f"SpellEffect rec={rec} fields={fields} recSize={recSize}")
        for i in range(rec):
            f.seek(20+i*recSize)
            b=f.read(recSize)
            ints=struct.unpack('<'+'I'*(recSize//4), b)
            floats=struct.unpack('<'+'f'*(recSize//4), b)
            # Id is ints[0], contains spell parent? check spec: SpellEffect has own Id, EffectSpellId at offset? In TC structure SpellEffectEntry: Id, Effect, DieSides, RealPointsPerLevel, BasePoints, Mechanic, TargetA, TargetB, Radius, Aura, Amplitude, Multiv, Chain, ItemType, MiscA, MiscB, TriggerSpell, ... then SpellId is separate field? Actually SpellEffect parent spell id is at field 1? Let's see header.
            # For debugging dump any where ints[0]==spell_id or TriggerSpell == spell_id? Trigger at 16?
            if ints[0]==spell_id:
                print(f"  idx {i}: Id={ints[0]} Effect={ints[1]} DieSides={ints[2]} RealP={floats[3]} BasePts={ints[4]} Mechanic={ints[5]} TargetA={ints[6]} TargetB={ints[7]} Radius={ints[8]} Aura={ints[9]} Amplitude={ints[10]} Multiv={floats[11]} Chain={ints[12]} ItemType={ints[13]} MiscA={ints[14]} MiscB={ints[15]} Trigger={ints[16]} SpellClassA={ints[17]} SpellClassB={ints[18]} SpellClassC={ints[19]} Family={ints[20]} Flags={ints[21]} DmgMult={floats[22]} Coef={floats[23]} RealDmgMult={floats[24]} Bonus={floats[25]} trig904? idx maybe")
                print(f"    raw ints={ints}")
                print(f"    raw floats={[round(x,3) for x in floats]}")
        # also search trigger==spell_id
        for i in range(rec):
            f.seek(20+i*recSize)
            b=f.read(recSize)
            ints=struct.unpack('<I'*27,b[:108])
            if ints[16]==spell_id:
                print(f"  TRIGGER usage: effect Id={ints[0]} triggers {spell_id}")

def dump_spell(spell_id):
    path=r"c:\Users\Admin\Desktop\TrinityCore\dbc\enUS\Spell.dbc"
    # Need to decode name: fields 48, many strings at end. Easier to use wowhead via DBC string area
    with open(path,'rb') as f:
        header=f.read(20)
        magic,rec,fields,recSize,strSize=struct.unpack('<4sIIII', header)
        print(f"\nSpell.dbc rec={rec} fields={fields} recSize={recSize} strSize={strSize}")
        data=f.read(rec*recSize)
        strings=f.read(strSize)
        for i in range(rec):
            off=i*recSize
            entry=data[off:off+recSize]
            sid=struct.unpack('<I',entry[:4])[0]
            if sid==spell_id:
                ints=struct.unpack('<I'*48, entry[:192])
                floats=struct.unpack('<f'*48, entry[:192])
                # Name is at field 21-22? In 4.3.4 Spell.dbc string offsets at 20+? Let's brute find string offsets that point into string block valid
                # Print all ints and try to resolve strings
                print(f"  Spell {sid} ints: {ints[:30]}")
                # try name at cols 20,21 as string offsets
                for col_idx in [20,21,22,30,35,40]:
                    off_val=ints[col_idx]
                    if 0 < off_val < strSize:
                        s=strings[off_val:off_val+80].split(b'\x00')[0]
                        try:
                            txt=s.decode('utf-8',errors='ignore')
                            if txt.strip():
                                print(f"    col {col_idx} offset {off_val} -> '{txt}'")
                        except: pass
                # also dump raw
                break
        else:
            print(f"Spell {spell_id} NOT FOUND in Spell.dbc (missing DBC entry)")

for sid in [86698,86760,103414,103494,103639,103640,103785,103851]:
    dump_spell(sid)
    dump_spell_effect(sid)
