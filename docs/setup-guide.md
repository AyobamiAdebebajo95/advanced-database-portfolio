# Setup Guide (Windows)

**Adebajo Ayobamidele** · Student ID 301931278 · GitHub: [github.com/AyobamiAdebebajo95/advanced-database-portfolio](https://github.com/AyobamiAdebebajo95/advanced-database-portfolio)

*Abbreviations are explained in [abbreviations.md](abbreviations.md).*

The tools needed for this portfolio, in the order you need them. Install the first six as needed. Docker turned out **not** to be needed: Portfolio 5 uses the MongoDB Atlas cloud cluster from Portfolio 4.

| # | Tool | Needed for | When |
|---|---|---|---|
| 1 | Git | Saving work to GitHub | Now |
| 2 | VS Code (Visual Studio Code) | Editing files | Now |
| 3 | PostgreSQL + pgAdmin (PostgreSQL Administration tool) | Portfolios 1, 2, 3, 5 | Now |
| 4 | draw.io | ER (Entity-Relationship) diagram | Now |
| 5 | Python | Creating test data | Before Portfolio 2 |
| 6 | MongoDB Atlas + Compass | Portfolios 4 and 5 | Before Portfolio 4 |
| 7 | Docker Desktop | Not needed (optional extra) | Skip |

---

## 1. Git
1. Download from **https://git-scm.com/download/win**
2. Run the installer and click **Next** on every screen (the defaults are fine).
3. Check it worked: open **Command Prompt** and type `git --version`

Then tell Git who you are (one time only):
```
git config --global user.name "Ayobami Adebajo"
git config --global user.email "ayobamiadebajo@gmail.com"
```

## 2. VS Code (Visual Studio Code)
1. Download from **https://code.visualstudio.com**
2. Install with the defaults. Tick **"Add to PATH"** if asked.

## 3. PostgreSQL + pgAdmin
1. Download the Windows installer from **https://www.postgresql.org/download/windows/** (choose the latest version).
2. Run it and keep these ticked: **PostgreSQL Server**, **pgAdmin 4**, **Command Line Tools**. Untick **Stack Builder** (not needed).
3. Set a password for the `postgres` user. **Write it down** — you will need it every time.
4. Keep the port as **5432**.
5. Open **pgAdmin 4** from the Start menu, enter your password, and you should see your server.

Create the project database: in pgAdmin, right-click **Databases → Create → Database**, name it `naijaautomart`, and click **Save**.

## 4. draw.io
Use it in the browser at **https://app.diagrams.net** (no install), or download the desktop app from **https://www.drawio.com**.

## 5. Python
1. Download from **https://www.python.org/downloads/**
2. On the first screen, **tick "Add python.exe to PATH"** before clicking Install. This step is easy to miss.
3. In Command Prompt, install the libraries we will use:
```
pip install faker psycopg2-binary pymongo
```

## 6. MongoDB + Compass (before Portfolio 4)
**What I used: MongoDB Atlas (cloud) + Compass.** Create a free **M0** cluster at https://cloud.mongodb.com, add a database user and your IP address (Network Access), then connect Compass with the `mongodb+srv://...` connection string. Nothing needs installing except Compass. The local install below is an alternative.

1. Download **MongoDB Community Server** from **https://www.mongodb.com/try/download/community**
2. Choose **Complete** setup, keep **"Install MongoDB as a Service"** ticked, and keep **"Install MongoDB Compass"** ticked.
3. Open **MongoDB Compass** and click **Connect** (the default `mongodb://localhost:27017` is correct).

## 7. Docker Desktop (optional, not used)
*Not needed: Portfolio 5 runs on the Atlas replica set. Kept here only in case you want to run servers locally.*

1. Download from **https://www.docker.com/products/docker-desktop/**
2. Install with the defaults (it uses WSL 2, the Windows Subsystem for Linux; let it install that if asked) and restart your PC (Personal Computer).
3. Open Docker Desktop and wait until it says **Engine running**.

---

## Get the project onto your computer
In Command Prompt:
```
cd %USERPROFILE%\Documents
git clone https://github.com/AyobamiAdebebajo95/advanced-database-portfolio.git
cd advanced-database-portfolio
code .
```
This opens the project in VS Code.

## Saving work to GitHub (do this a few times each week)
```
git add .
git commit -m "Short note on what you did"
git push
```
The first push will open a GitHub sign-in window. Sign in as **AyobamiAdebebajo95**.

## Quick check
- [ ] `git --version` works
- [ ] pgAdmin opens and shows the `naijaautomart` database
- [ ] `python --version` works
- [ ] The project folder is in Documents and opens in VS Code
