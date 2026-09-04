import pathlib, re, csv, io
tdb = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\TDB_full_world_434.22011_2022_01_09.sql")
target="77207"
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for line in f:
        if line.startswith("INSERT INTO `item_template`") and f"({target}," in line:
            print("found line len", len(line))
            # extract row via simple regex for that item
            # find position
            idx=line.find(f"({target},")
            print(line[idx: idx+3000][:2000])
            # try to parse that row fully: find next "),(" after idx
            # search for closing ");" or "),("
            # Use slice from idx to next "),(" 
            end=line.find("),(", idx)
            if end==-1:
                end=line.find("),", idx)
            row=line[idx: end+1] if end!=-1 else line[idx: idx+3000]
            print("\n---ROW---\n", row[:2000])
            # now try csv parse
            inner=row[1:-1]  # remove outer parens
            # Use csv to get fields
            # Need cols
            break

# also check item_template cols
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
            clean=seen[1:]
            print("cols clean", clean)
            print("entry idx", clean.index("entry"))
            print("ItemLevel idx", clean.index("ItemLevel"))
            print("name idx", clean.index("name"))
            # count cols
            print(len(clean))
            break
