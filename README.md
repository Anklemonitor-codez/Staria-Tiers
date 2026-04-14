# PvP Tiers — Setup Guide (Supabase + GitHub Pages)

## Structure

```
pvptiers-supa/
├── public/
│   └── index.html            ← Frontend + Admin Panel (GitHub Pages)
├── supabase/
│   └── schema.sql            ← Run once in Supabase SQL Editor
├── .github/
│   └── workflows/
│       └── deploy.yml        ← Auto-deploy + config injection
└── README.md
```

---

## Step 1 — Supabase Setup

### 1a. Create a project
1. Go to [supabase.com](https://supabase.com) → **New Project**
2. Pick a name, region, and a strong database password → **Create**

### 1b. Run the schema
1. Dashboard → **SQL Editor** → **New Query**
2. Paste the contents of `supabase/schema.sql` and click **Run**
3. This creates the `players` table, indexes, RLS policies, and enables Realtime

### 1c. Create your admin account
1. Dashboard → **Authentication** → **Users** → **Invite User**
2. Enter your email and a strong password — this is the admin login for the panel
3. Note down your email exactly as entered

### 1d. Get your keys
Go to **Settings → API** and copy:
- **Project URL** (looks like `https://xxxxxxxxxxxx.supabase.co`)
- **anon / public key** (safe to expose — RLS protects writes)

---

## Step 2 — GitHub Pages

### 2a. Push to GitHub
Create a new GitHub repository and push this folder.

### 2b. Enable GitHub Pages
- Go to **Settings → Pages → Source → GitHub Actions**

### 2c. Add Repository Secrets
Go to **Settings → Secrets and Variables → Actions → New repository secret**

| Secret name | Value |
|---|---|
| `SUPABASE_URL` | Your Supabase Project URL |
| `SUPABASE_ANON_KEY` | Your Supabase anon/public key |
| `ADMIN_EMAIL` | The email you created in Step 1c |

### 2d. Deploy
Push any commit to `main` — GitHub Actions will inject the config and deploy.
Your site will be at: `https://YOUR_USERNAME.github.io/YOUR_REPO`

---

## Using the Admin Panel

1. Click **Admin** button in the top-right corner
2. Enter your Supabase Auth password
3. You're in — full CRUD on players:

### Add a player
- Admin → **Add Player** tab
- Fill in username, optional notes
- Set ranks for each gamemode (or leave blank = unranked)
- Click **Add Player**

### Edit a player
- Admin → **Player List** → **Edit** button
- Change any ranks or notes → **Save Changes**

### Delete a player
- Admin → **Player List** → **Delete** → confirm

Changes appear on the public leaderboard **instantly** via Supabase Realtime.

---

## Rank System

| Rank | Tier | Description |
|---|---|---|
| **HT1** | High Tier 1 | Best of the best |
| **HT2** | High Tier 2 | Very strong |
| **HT3** | High Tier 3 | Strong |
| **HT4** | High Tier 4 | Above average |
| **HT5** | High Tier 5 | Decent |
| **LT1** | Low Tier 1 | Below average |
| **LT2** | Low Tier 2 | Developing |
| **LT3** | Low Tier 3 | Learning |
| **LT4** | Low Tier 4 | Beginner |
| **LT5** | Low Tier 5 | New to PvP |

---

## Gamemodes

`Crystal` `Mace` `Sword` `Axe` `UHC` `Cart` `SpearMace` `Pot` `SMP`

---

## Read Budget

| Scenario | Reads |
|---|---|
| First visit (no cache) | 1 Supabase query |
| Return visit within 5 min | 0 (served from localStorage) |
| After 5-min TTL expires | 1 query |
| Realtime rank update | 1 re-fetch triggered by server event |
| 1,000 daily visitors (avg 2 visits) | ~1,000–2,000 queries/day |

Supabase free tier: **500MB database, unlimited API requests** — you'll never hit a limit.

---

## Local Development (optional)

If you want to test locally without deploying:
1. Open `public/index.html`
2. Replace the three `YOUR_*` placeholders at the top of the `<script>` block with your real values
3. Open in browser — no build step needed
