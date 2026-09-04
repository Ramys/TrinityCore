import pathlib, re

tdb = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\TDB_full_world_434.22011_2022_01_09.sql")
# search for creature_template 55265 lootid
# read in chunks to find row
needle = b"(55265,"
count=0
with open(tdb, "rb") as f:
    data = f.read()
    # find creature_template inserts
    for m in re.finditer(b"INSERT INTO `creature_template` VALUES", data):
        start = m.start()
        end = data.find(b";", start)
        chunk = data[start:end+1]
        if b"55265" in chunk:
            # find all rows
            rows = re.findall(br"\(55265,[^)]+?\)", chunk)
            for r in rows:
                print(r[:1200].decode(errors="ignore"))
                count+=1
            if count>0:
                break

print("--- loot template search ---")
# find loot entry exact
loot_count=0
with open(tdb, "rb") as f:
    # stream line by line via reading text chunks
    txt = f.read().decode(errors="ignore")
    # find INSERT creature_loot_template
    for m in re.finditer(r"INSERT INTO `creature_loot_template` VALUES (.*?);", txt, re.S):
        vals = m.group(1)
        if "(55265," in vals:
            # count entries
            cnt = vals.count("(55265,")
            print(f"found loot insert with {cnt} entries for 55265")
            print(vals[:3000])
            loot_count = cnt
            break
if loot_count==0:
    print("NO loot for 55265 in TDB root - loot missing => cause 10N sem loot mesmo sem bug script")

# check sql/old loot file
old = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\sql\old\4.3.4\world\13_2016_11_06\2016_10_09_02_world.sql")
txt2 = old.read_text(encoding="utf-8", errors="ignore")
m2 = re.search(r"DELETE FROM `creature_loot_template` WHERE `entry` = 55265;.*?INSERT INTO `creature_loot_template`.*?;", txt2, re.S)
if m2:
    s = m2.group(0)
    print("\n--- OLD FILE loot ---")
    print(s[:4000])
    cnt2 = s.count("(55265,")
    print(f"old loot entries {cnt2}")

# check creature_template in old for lootid/difficulty
m3 = re.search(r"UPDATE `creature_template` SET `lootid` = 55265", txt2)
print(f"\nold lootid update exists: {bool(m3)}")
# find difficulty entries definition
old2 = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\sql\old\4.3.4\world\12_2016_09_28\2016_09_20_08_world.sql")
if old2.exists():
    t = old2.read_text(encoding="utf-8", errors="ignore")
    for line in t.splitlines():
        if "55265" in line and "difficulty" in line.lower():
            print(line.strip()[:800])
