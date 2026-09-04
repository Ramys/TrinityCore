import pathlib
tdb=pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\TDB_full_world_434.22011_2022_01_09.sql")
needle="77207"
with open(tdb, encoding="utf-8", errors="ignore") as f:
    for i,line in enumerate(f):
        if needle in line:
            print(f"line {i} len {len(line)} snippet {line[line.find(needle)-200: line.find(needle)+800][:1500]}")
            break
    else:
        print("not found")
