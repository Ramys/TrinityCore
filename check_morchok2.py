import pathlib, re

p = pathlib.Path(r"c:\Users\Admin\Desktop\TrinityCore\src\server\scripts\Kalimdor\CavernsOfTime\DragonSoul\boss_morchok.cpp")
txt = p.read_text(encoding="utf-8", errors="ignore")
lines = txt.splitlines()
# dump 240-360
for i in range(240, 360):
    if i < len(lines):
        print(f"{i+1:4}: {lines[i]}")

print("\n===== DamageTaken / Shared Health =====\n")
# find Shared Health block
for i,l in enumerate(lines):
    if "Shared Health" in l or "HealthBelowPctDamaged" in l or "SetHealth" in l:
        # print context 5 lines
        for j in range(max(0,i-6), min(len(lines), i+12)):
            print(f"{j+1:4}: {lines[j]}")
        print("---")

print("\n===== Kohcrom JustDied =====\n")
for i,l in enumerate(lines):
    if "class npc_morchok_kohcrom" in l:
        for j in range(i, min(len(lines), i+200)):
            print(f"{j+1:4}: {lines[j]}")
            if j>i+150 and "Register" in lines[j]:
                break
        break
