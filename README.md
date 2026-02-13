# Fisch FarmHub - Modular Roblox Script

A modular Lua script for Roblox Fisch game with organized code structure.

## 🚀 Quick Start (สำหรับผู้ใช้)

### วิธีใช้งาน (ให้คนอื่นรัน)

ให้คนอื่นใช้โค้ดนี้ใน Roblox executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO_NAME/main/Main_Github.lua"))()
```

**อย่าลืมแก้:**
- `YOUR_USERNAME` → ชื่อ GitHub ของคุณ
- `YOUR_REPO_NAME` → ชื่อ repository

## 📁 Project Structure

```
modules/
├── config/
│   └── Settings.lua          # ตัวแปรการตั้งค่าทั้งหมด
├── services/
│   └── Services.lua          # Roblox Services
├── data/
│   └── Data.lua              # ข้อมูล Locations, Rods, Totems
├── utils/
│   └── Utils.lua             # Helper Functions
├── ui/
│   ├── MainUI.lua            # Fluent UI
│   ├── LogUI.lua             # Log Panel
│   ├── InfoUI.lua            # Server Info Panel
│   ├── FlyUI.lua             # Fly Control
│   └── TabSetup.lua          # Tab Configuration
└── logic/
    ├── AutoFish.lua          # ระบบตกปลา
    ├── AutoTotem.lua         # Auto Totem
    ├── AutoPotion.lua        # Auto Potion
    ├── AutoSell.lua          # Auto Sell
    ├── Character.lua         # Fly, ESP, Noclip
    └── Teleport.lua          # Teleport System

Main.lua                      # สำหรับ local file (ใช้ readfile)
Main_Github.lua               # สำหรับ GitHub (ใช้ HttpGet)
```

## 🔧 การตั้งค่า GitHub

### ขั้นตอนอัพโหลด:

1. **สร้าง Repository ใหม่** บน GitHub
2. **อัพโหลดไฟล์ทั้งหมด** ไปยัง repository
3. **แก้ URL ใน `Main_Github.lua`:**
   ```lua
   local GITHUB_BASE = "https://raw.githubusercontent.com/USERNAME/REPO_NAME/main/modules/"
   ```

### ตัวอย่างโครงสร้างบน GitHub:

```
https://github.com/yossa/fisch-script/
├── modules/
│   ├── config/Settings.lua
│   ├── services/Services.lua
│   ├── data/Data.lua
│   ├── utils/Utils.lua
│   ├── ui/
│   │   ├── MainUI.lua
│   │   ├── LogUI.lua
│   │   ├── InfoUI.lua
│   │   ├── FlyUI.lua
│   │   └── TabSetup.lua
│   └── logic/
│       ├── AutoFish.lua
│       ├── AutoTotem.lua
│       ├── AutoPotion.lua
│       ├── AutoSell.lua
│       ├── Character.lua
│       └── Teleport.lua
├── Main_Github.lua
└── README.md
```

## 📝 การใช้งานแบบ Local (สำหรับทดสอบ)

ถ้าต้องการทดสอบบนเครื่องตัวเองก่อน:

```lua
-- ใช้ใน Roblox executor
loadstring(readfile("Main.lua"))()
```

**ข้อกำหนด:** ต้องมีไฟล์ทั้งหมดใน workspace ของ executor

## 🔄 การอัพเดท Script

หลังจากแก้ไขโค้ด:

1. Commit และ Push ขึ้น GitHub
2. รอ 2-5 นาทีให้ GitHub raw URL อัพเดท
3. ผู้ใช้รัน script ใหม่ได้เลย (ไม่ต้องเปลี่ยน URL)

## ⚠️ ข้อควรระวัง

- GitHub raw URL อาจมี caching (ใช้เวลา 2-5 นาทีในการอัพเดท)
- อย่าลืมตั้ง repository เป็น **Public** ถ้าต้องการให้คนอื่นใช้
- ห้ามเผยแพร่ URL ที่มี username/repo ส่วนตัวในที่สาธารณะ (ถ้าเป็น private repo)

## 🎯 Features

- ✅ Auto Fish (ตกปลาอัตโนมัติ)
- ✅ Auto Shake (เขย่าอัตโนมัติ)
- ✅ Auto Totem (ใช้ Totem ตามเวลา)
- ✅ Auto Potion (กินยาตามเวลา)
- ✅ Auto Sell (ขายของอัตโนมัติ)
- ✅ Fly System (บินได้)
- ✅ Player ESP (มองเห็นผู้เล่น)
- ✅ Teleport (วาร์ปไปตำแหน่งต่างๆ)
- ✅ Mobile Support (รองรับมือถือ)

## 📄 License

ใช้งานได้ฟรี แต่ห้ามนำไปขาย

---

**Developed by:** [Your Name]
**Version:** 1.1
**Last Updated:** 2026-02-14
