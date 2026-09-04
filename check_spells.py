import struct, pathlib

def scan_spell_dbc(path, ids):
    with open(path, 'rb') as f:
        h = f.read(20)
        magic, rec, fields, recSize, strSize = struct.unpack('<4sIIII', h)
        print(f"Spell.dbc: rec={rec} fields={fields} recSize={recSize} strSize={strSize}")
        ids_set = set(ids)
        found = {}
        for i in range(rec):
            f.seek(20 + i*recSize)
            b = f.read(recSize)
            sid = struct.unpack('<I', b[:4])[0]
            if sid in ids_set:
                found[sid]=i
                print(f"  FOUND Spell {sid} at idx {i}")
        for sid in ids:
            if sid not in found:
                print(f"  MISSING Spell {sid} in DBC")

def scan_effect_dbc(path, trigger_ids, effect_spell_ids):
    # SpellEffect.dbc layout for 4.3.4: check fields
    with open(path, 'rb') as f:
        h = f.read(20)
        magic, rec, fields, recSize, strSize = struct.unpack('<4sIIII', h)
        print(f"\nSpellEffect.dbc: rec={rec} fields={fields} recSize={recSize}")
        # fields unknown, need to detect EffectSpellId position?
        # Common layout: Id, Effect, EffectDieSides, EffectRealPointsPerLevel, EffectBasePoints, EffectMechanic, EffectImplicitTargetA, EffectImplicitTargetB, EffectRadiusIndex, EffectApplyAuraName, EffectAmplitude, EffectMultipleValue, EffectChainTarget, EffectItemType, EffectMiscValue, EffectMiscValueB, EffectTriggerSpell, ...
        # Let's dump header for 86760 trigger source
        # Brute force: scan for entries where EffectTriggerSpell == target
        # We need to know offset of TriggerSpell: for 4.3.4 it is field 16? let's try to parse as ints+f
        # Instead just read all ints and search
        targets = set(effect_spell_ids)  # spells that are source
        # Also scan for trigger value 86760
        trigger_val = 86760
        hits = []
        for i in range(rec):
            f.seek(20 + i*recSize)
            b = f.read(recSize)
            # unpack as ints
            # recSize likely 40+ bytes, unpack as <I/f mix?
            # For detection just unpack as <I for all 4-byte chunks
            ints = struct.unpack('<' + 'I'*(recSize//4), b[:recSize//4*4])
            # spellID is ints[1]? Actually SpellEffect id layout: [0]=Id, [1]=EffectID? Let's check typical: offset 4 = Effect,  56?
            # Simpler: check if any int == 86698 (as parent spell) or 86760 (as trigger)
            if 86698 in ints or 86760 in ints:
                # parent spell id maybe at index 1 or 4?
                # dump first 20 ints
                print(f"  Effect idx {i} ints[0:18]={ints[0:18]} floats? checking")
                if 86698 in ints:
                    # find position
                    pos = ints.index(86698)
                    print(f"    -> 86698 at pos {pos}")
                if 86760 in ints:
                    pos = ints.index(86760)
                    print(f"    -> 86760 at pos {pos}")
                hits.append(i)
                if len(hits)>20:
                    break
        if not hits:
            print("  no effect entries containing 86698/86760 as int")
        # Also lookup entries for spell 86698 parent
        # SpellDifficulty ties? Let's also check Spell.dbc effect field count

ids = [86698, 86760, 103414, 103640, 103639, 103494, 103785, 103851, 109017, 109070, 55265]
scan_spell_dbc(r"c:\Users\Admin\Desktop\TrinityCore\dbc\enUS\Spell.dbc", ids)
scan_effect_dbc(r"c:\Users\Admin\Desktop\TrinityCore\dbc\enUS\SpellEffect.dbc", [86698], [86698])
