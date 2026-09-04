import pathlib, re, csv, io

tdb = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\TDB_full_world_434.22011_2022_01_09.sql")
# 1) cols
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("CREATE TABLE `creature_loot_template`"):
            # read until ) ENGINE
            buf=line
            while ") ENGINE" not in buf:
                buf+=next(f)
            cols = re.findall(r"`(\w+)`", buf)
            print("creature_loot_template cols", cols)
            break

with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("CREATE TABLE `reference_loot_template`"):
            buf=line
            while ") ENGINE" not in buf:
                buf+=next(f)
            cols = re.findall(r"`(\w+)`", buf)
            print("reference_loot_template cols", cols)
            break

with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("CREATE TABLE `creature_template`"):
            buf=line
            while ") ENGINE" not in buf:
                buf+=next(f)
            cols = re.findall(r"`(\w+)`", buf)
            print("creature_template cols index", {c:i for i,c in enumerate(cols)})
            break

# 2) find creature_template rows for morchok family
import re
pattern = re.compile(r"\((\d+),")
# use quick grep via python streaming
entries = ["55265","57409","57771","57772","57773"]
found = {}
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("INSERT INTO `creature_template`"):
            for e in entries:
                if f"({e}," in line:
                    # extract row via regex split on ),(
                    # find chunk with that entry
                    # use find all rows
                    rows = re.findall(r"\([^)]+\)", line)
                    for r in rows:
                        if r.startswith(f"({e},"):
                            # parse csv with quote "'"
                            inner = r[1:-1]
                            reader = csv.reader(io.StringIO(inner), quotechar="'", skipinitialspace=True)
                            fields = next(reader)
                            found[e]=fields
                            print(f"found {e} fields len {len(fields)} lootid {fields[43] if len(fields)>43 else 'NA'} diff1 {fields[1]} diff2 {fields[2]} diff3 {fields[3]} ScriptName {fields[-3] if len(fields)>5 else 'NA'} AIName {fields[-4] if len(fields)>5 else 'NA'}")
            if len(found)>=len(entries):
                break
print(found.keys())

# 3) creature_loot_template for 55265 and difficulties
for target in ["55265","57409","57771","57772","57773"]:
    cnt=0
    lootmodes=set()
    with open(tdb, encoding="utf-8", errors="ignore") as f:
        for line in f:
            if line.startswith("INSERT INTO `creature_loot_template`") and f"({target}," in line:
                rows = re.findall(r"\([^)]+\)", line)
                for r in rows:
                    if r.startswith(f"({target},"):
                        cnt+=1
                        inner = r[1:-1]
                        reader = csv.reader(io.StringIO(inner), quotechar="'", skipinitialspace=True)
                        fields = next(reader)
                        # cols for creature_loot: Entry,Item,Chance,lootmode,groupid,Reference,MinCount,MaxCount?
                        # actual cols from create
                        lootmodes.add(fields[3])
                if cnt>0:
                    print(f"entry {target} count {cnt} lootmodes {lootmodes} sample {r[:120]}")
                    break
        if cnt==0:
            print(f"entry {target} count 0")

# 4) reference_loot_template check for LFR items
# LFR item ids known for DS: look for items 771xx? We dump reference entries that contain LFR ids
# Instead dump what item IDs appear in 55265 loot
print("\n--- items for 55265 ---")
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("INSERT INTO `creature_loot_template`") and "(55265," in line:
            rows = re.findall(r"\([^)]+\)", line)
            items=[]
            for r in rows:
                if r.startswith("(55265,"):
                    inner=r[1:-1]
                    reader=csv.reader(io.StringIO(inner), quotechar="'", skipinitialspace=True)
                    fields=next(reader)
                    items.append((fields[1], fields[2], fields[3], fields[5])) # item, chance, lootmode, Reference
            # print first 30
            for it in items[:40]:
                print(it)
            # check if any Reference !=0
            refs=[x for x in items if x[3] not in ("0","")]
            print("refs in 55265", refs[:10])
            break

# 5) search item_template for mixed items to identify normal vs heroic vs LFR by item level?
# items 783xx vs 772xx vs 788xx token etc - we will later map
