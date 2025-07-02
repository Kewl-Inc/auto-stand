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

### Prerequisites

- Flutter SDK
- Node.js (for web Slack integration)
- OpenAI API key
- Slack webhook URL (optional)

### Configuration

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Kewl-Inc/auto-stand.git
   cd auto-stand
   ```

2. **Set up API keys (using environment variables):**
   
   ```bash
   ./setup-env.sh
   # Or manually:
   cp .env.example .env
   ```
   
   Edit `.env` and add your keys:
   ```env
   OPENAI_API_KEY=your-openai-api-key-here
   SLACK_WEBHOOK_URL=your-slack-webhook-url-here
   ```
   
   The app will automatically load these from the .env file.

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

### Running the App

**For Desktop/Mobile:**
```bash
flutter run
```

**For Web (with Slack integration):**
```bash
# Terminal 1: Start proxy server
cd proxy-server
npm install
npm start

# Terminal 2: Run Flutter web
flutter run -d chrome
```

Or use the convenience script:
```bash
./start-dev.sh
```

## 📋 Features

- 🤖 AI-powered standup generation using GPT-4
- 📝 Simple input interface for work items
- 📋 Copy to clipboard functionality
- 💬 Direct Slack integration
- 🎨 Clean, modern Flutter UI
- 🌐 Cross-platform (Web, iOS, Android, macOS)

## 🧪 MVP Test Scope

- Just one team (3–6 people)
- Manual-ish data pulls for now (drop links, it parses)
- One-week async standup trial
- Compare with prior standup efficiency and team awareness

## 🔑 Getting API Keys

### OpenAI API Key
1. Visit https://platform.openai.com/api-keys
2. Create a new API key
3. Add to your configuration

### Slack Webhook
1. Go to https://api.slack.com/apps
2. Create new app or select existing
3. Enable "Incoming Webhooks"
4. Add webhook to workspace
5. Copy the webhook URL