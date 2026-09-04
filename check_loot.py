import pathlib, re

# find CREATE TABLE for creature_template to get column order
tdb = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\TDB_full_world_434.22011_2022_01_09.sql")
text = None
# get first 200k chars around CREATE TABLE creature_template
with open(tdb, encoding="utf-8", errors="ignore") as f:
    data = f.read(8000000)  # 8MB should include header tables
    # find creature_template create
    m = re.search(r"CREATE TABLE `creature_template`.*?;", data, re.S)
    if m:
        create = m.group(0)
        print(create[:4000])
        print("\n--- COLS ---\n")
        cols = re.findall(r"`(\w+)`", create)
        print(cols)
        print(f"\nNum cols {len(cols)}")
        # find lootid index
        if "lootid" in cols:
            print(f"lootid index {cols.index('lootid')}")
        # also search loot insert
        print("\n--- creature_template 55265 row ---")
        # find INSERT with 55265
        for mm in re.finditer(r"INSERT INTO `creature_template` VALUES (.*?);", data, re.S):
            vals = mm.group(1)
            if "55265" in vals:
                # split rows
                # rows are like (55265,...,15595)
                rows = re.findall(r"\([^)]+\)", vals)
                for r in rows:
                    if r.startswith("(55265,"):
                        print(r[:3000])
                        # parse csv respecting quotes
                        # naive split by , but handle quotes
                        import csv, io
                        inner = r[1:-1]
                        # use csv
                        reader = csv.reader(io.StringIO(inner), quotechar="'", skipinitialspace=True)
                        fields = next(reader)
                        # map cols to fields
                        print("\nParsed fields count", len(fields))
                        for idx,c in enumerate(cols):
                            if idx < len(fields):
                                if c in ("entry","lootid","KillCredit1","KillCredit2","ScriptName","AIName","VerifiedBuild"):
                                    print(f"{idx:2} {c:20} = {fields[idx]}")
                        break
                break

# also check creature_loot_template
print("\n--- creature_loot_template 55265 ---")
with open(tdb, encoding="utf-8", errors="ignore") as f:
    # stream
    count=0
    for line in f:
        if "creature_loot_template" in line and "55265" in line:
            print(line.strip()[:4000])
            count+=1
            if count>5:
                break
    if count==0:
        print("NOT FOUND in TDB root")

# check base dev
base = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\sql\base\dev\world_database.sql")
print("\n--- base dev 55265 ---")
with open(base, encoding="utf-8", errors="ignore") as f:
    cnt=0
    for line in f:
        if "55265" in line and "creature" in line.lower():
            print(line.strip()[:4000])
            cnt+=1
            if cnt>10:
                break

# check sql/updates/world for loot overrides
import pathlib as pl
upd_dir = pl.Path(r"c:\Users\Admin\Desktop\TrinityCore\sql\updates\world")
print("\n--- grep sql/updates/world for 55265 loot ---")
import subprocess, sys
try:
    import os, glob
    for p in pl.Path(r"c:\Users\Admin\Desktop\TrinityCore\sql").rglob("*.sql"):
        try:
            txt = p.read_text(encoding="utf-8", errors="ignore")
            if "55265" in txt and "loot" in txt.lower():
                print(f"FOUND {p}")
                # print context
                for line in txt.splitlines():
                    if "55265" in line and "loot" in line.lower():
                        print(line[:600])
        except: pass
except Exception as e:
    print(e)
