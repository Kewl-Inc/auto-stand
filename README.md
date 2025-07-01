# 🔧 AutoStand – Kill Your Standup

Replace daily standups with an AI-generated personal + team digest from your actual work activity.

## 🎯 Goal

AutoStand automatically generates daily standup updates by analyzing your work across multiple platforms (Notion, Slack, GitHub, Google Docs, Figma, email, calendar) and creates human-sounding summaries for you and your team.

## 🔁 Core Flow

1. **Template Setup** (one-time):
   - Pick your team's daily update sections:
     - "What I did"
     - "What I'm blocked by"
     - "What I learned"
     - "Show & Tell" (screenshots, Figma, Looms)
     - "Prototype links"

2. **Auto Ingestion** (daily):
   - AI pulls from Notion, Slack, GitHub, Google Docs, Figma, email, calendar
   - Parses what you wrote, made, sent, shipped, designed

3. **Digest Output** (at a set time):
   - Clean, human-sounding summary from each person
   - Rolled into a team update
   - Delivered via Slack, email, or hosted URL

## 💥 Magic Moment

You see your own day reflected back to you better than you could've phrased it yourself. Then your teammate posts "whoa this is great, didn't even know you were working on that."

## 🚀 Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## 🧪 MVP Test Scope

- Just one team (3–6 people)
- Manual-ish data pulls for now (drop links, it parses)
- One-week async standup trial
- Compare with prior standup efficiency and team awareness