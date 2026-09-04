import pathlib, re
tdb = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\TDB_full_world_434.22011_2022_01_09.sql")
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("CREATE TABLE `creature_loot_template`"):
            buf=line
            while ") ENGINE" not in buf:
                buf+=next(f)
            cols=re.findall(r"`(\w+)`", buf)
            seen=[]
            for c in cols:
                if c not in seen:
                    seen.append(c)
            print("creature_loot seen", seen)
            break
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("CREATE TABLE `item_template`"):
            buf=line
            while ") ENGINE" not in buf:
                buf+=next(f)
            cols=re.findall(r"`(\w+)`", buf)
            seen=[]
            for c in cols:
                if c not in seen:
                    seen.append(c)
            print("item_template seen len", len(seen))
            print(seen[:40])
            if "ItemLevel" in seen:
                print("ItemLevel pos", seen.index("ItemLevel"))
            break
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("INSERT INTO `creature_loot_template`") and "(55265," in line:
            print(line[:800])
            rows=re.findall(r"\([^)]+\)", line)
            print("rows", len(rows))
            for r in rows[:3]:
                print(r[:300])
            break
