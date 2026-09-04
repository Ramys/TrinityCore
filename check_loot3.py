import pathlib, re
tdb = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\TDB_full_world_434.22011_2022_01_09.sql")
found=False
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for idx,line in enumerate(f,1):
        if "creature_loot_template" in line and "(55265," in line:
            print(f"line {idx} loot 55265 found")
            # count entries in this line
            cnt=line.count("(55265,")
            print(f"cnt {cnt}")
            print(line[:4000])
            found=True
            break
        # also handle multi-line INSERT spanning lines
        if "INSERT INTO `creature_loot_template`" in line:
            # peek next logic handled by line-by-line
            pass
if not found:
    print("NO line with creature_loot_template + 55265 in TDB root => loot table vazio na raiz")

# check any creature_loot_template entry at all near morchok
found2=False
with open(tdb, encoding="utf-8", errors="ignore") as f:
    buf=""
    for line in f:
        if "INSERT INTO `creature_loot_template`" in line:
            buf=line
            # need to handle that INSERT may be very long single line
            if "55265" in buf:
                print("INSERT loot contains 55265")
                found2=True
                break
            # if not, continue streaming but also check if 55265 appears in next lines (unlikely, loot inserts are single line)
            pass
        if "55265" in line and "creature_loot" in line.lower():
            print(line[:1000])
            found2=True
            break
if not found2:
    print("scan2: nenhum loot 55265 na raiz pinada")

# check creature_template lootid
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("INSERT INTO `creature_template`") and "(55265," in line:
            # extract row
            m=re.search(r"\(55265,[^)]+\)",line)
            if m:
                print("creature_template row 55265:")
                print(m.group(0)[:2000])
            break
