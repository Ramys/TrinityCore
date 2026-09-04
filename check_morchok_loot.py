import pathlib, re

p = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\src\server\scripts\Kalimdor\CavernsOfTime\DragonSoul\boss_morchok.cpp")
lines = p.read_text(encoding="utf-8", errors="ignore").splitlines()
for i,l in enumerate(lines[100:360], start=101):
    # show JustDied region
    print(f"{i:4}: {l}")
print("\n--- END JustDied region ---\n")

# DB checks
tdb = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\TDB_full_world_434.22011_2022_01_09.sql")
# stream search for morchok loot
import re
found = []
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if "55265" in line:
            low = line.lower()
            if "creature_template" in low or "creature_loot" in low or "lootid" in low:
                print(line.strip()[:2000])
                found.append(line)
                if len(found) >= 30:
                    break

print("\n--- base dev world_database ---")
base = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\sql\base\dev\world_database.sql")
found2=[]
with open(base, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if "55265" in line and ("creature_template" in line.lower() or "creature_loot" in line.lower()):
            print(line.strip()[:2000])
            found2.append(line)
            if len(found2)>=20:
                break

# also check kohcrom 57773
print("\n--- kohcrom 57773 checks ---")
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if "57773" in line and ("creature_template" in line.lower() or "lootid" in line.lower()):
            print(line.strip()[:1500])
            break
