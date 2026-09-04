import pathlib, re, csv, io
tdb = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\TDB_full_world_434.22011_2022_01_09.sql")
# get true creature_loot column order via CREATE: Entry,Item,Reference,Chance,QuestRequired,IsCurrency,LootMode,GroupId,MinCount,MaxCount
# So positions: 0 Entry,1 Item,2 Reference,3 Chance,4 QuestRequired,5 IsCurrency,6 LootMode,7 GroupId,8 MinCount,9 MaxCount

# find items for 55265 with their LootMode
items=[]
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("INSERT INTO `creature_loot_template`") and "(55265," in line:
            # need to extract all rows for 55265 - line is huge ~800k, contains 20586 rows total, but 55265 chunk inside
            # find all occurrences via regex
            rows=re.findall(r"\(55265,[^)]+\)", line)
            for r in rows:
                inner=r[1:-1]
                parts=inner.split(",")
                # parts: 0 Entry,1 Item,2 Reference,3 Chance,4 QuestRequired,5 IsCurrency,6 LootMode,7 GroupId,8 MinCount,9 MaxCount,10 Comment
                items.append((parts[1].strip(), parts[3].strip(), parts[6].strip(), parts[7].strip()))
            break
print("items count", len(items))
# group by LootMode
from collections import Counter
c=Counter(x[2] for x in items)
print(c)
for lootmode, cnt in c.items():
    print(f"LootMode {lootmode} count {cnt}")
    # show sample items
    sample=[x for x in items if x[2]==lootmode][:10]
    print(sample)

# Need to map LootMode values: in SharedDefines LOOT_MODE_DEFAULT=1, HARD_1=2, HARD_2=4, HARD_3=8, HARD_4=16, JUNK_FISH=0x8000
# For DS normal/heroic/LFR, how are they distinguished? Likely not via LootMode but via difficulty_entry lootid separate?
# Check if all items have LootMode 1 => mixing because same lootid for all difficulties
# If mixing normal/heroic/LFR, need to check ItemLevel to differentiate

# quick item level check for sample items via item_template
target_ids=[x[0] for x in items]
# get ItemLevel map
# parse item_template CREATE to get ItemLevel index
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("CREATE TABLE `item_template`"):
            buf=line
            while ") ENGINE" not in buf:
                buf+=next(f)
            cols=re.findall(r"`(\w+)`", buf)
            seen=[]
            for cc in cols:
                if cc not in seen:
                    seen.append(cc)
            cols_clean=seen[1:]
            idx_entry=cols_clean.index("entry")
            idx_ilvl=cols_clean.index("ItemLevel")
            idx_name=cols_clean.index("name")
            print("item_template cols_clean len", len(cols_clean), "ItemLevel idx", idx_ilvl)
            break

found={}
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if not line.startswith("INSERT INTO `item_template`"):
            continue
        # quick filter
        if not any(f"({tid}," in line for tid in target_ids[:20]):
            # check all
            if not any(tid in line for tid in target_ids):
                continue
        # parse
        vals_part=line[line.find("VALUES")+6:].strip().rstrip(";")
        if vals_part.startswith("("):
            vals_part=vals_part[1:-1]
            raw_rows=vals_part.split("),(")
            for raw in raw_rows:
                # get entry id
                comma=raw.find(",")
                if comma==-1:
                    continue
                eid=raw[:comma].strip()
                if eid in target_ids and eid not in found:
                    try:
                        reader=csv.reader(io.StringIO(raw), quotechar="'", escapechar="\\", skipinitialspace=True)
                        fields=next(reader)
                        ilvl=fields[idx_ilvl] if idx_ilvl < len(fields) else "?"
                        name=fields[idx_name] if idx_name < len(fields) else ""
                        found[eid]=(ilvl,name)
                    except:
                        pass
        if len(found)>=len(set(target_ids)):
            break
print("found levels", len(found))
for it, ch, lm, grp in items:
    ilvl,name=found.get(it, ("?","?"))
    print(f"{it} ilvl {ilvl} LootMode {lm} Chance {ch} name {name} ")
