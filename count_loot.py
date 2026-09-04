import pathlib, re
p = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\TDB_full_world_434.22011_2022_01_09.sql")
cnt=0
found_lines=[]
with open(p, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if "creature_loot_template" in line:
            # count occurrences of (55265,
            c = line.count("(55265,")
            if c>0:
                cnt+=c
                found_lines.append((len(line), c))
print(f"total (55265, entries in TDB root: {cnt}")
print(found_lines[:5])
# find old file total too
p2 = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\sql\old\4.3.4\world\13_2016_11_06\2016_10_09_02_world.sql")
cnt2=0
with open(p2, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if "creature_loot_template" in line:
            c=line.count("(55265,")
            cnt2+=c
print(f"old file total (55265, entries: {cnt2}")
# check creature_template lootid for 55265
with open(p, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("INSERT INTO `creature_template`") and "(55265," in line:
            # extract row
            m=re.search(r"\(55265,.*?,(\d+),0,0,0,0,0,0,0,0,0", line) # naive
            # better parse csv splitted
            import re as re2
            rows=re2.findall(r"\([^)]+\)", line)
            for r in rows:
                if r.startswith("(55265,"):
                    # split by comma not perfect
                    parts=r[1:-1].split(",")
                    print(f"row parts {len(parts)}")
                    print(f"parts[0:5]={parts[0:5]}")
                    print(f"parts around lootid index guess 38-45: {parts[36:46]}")
                    break
            break
