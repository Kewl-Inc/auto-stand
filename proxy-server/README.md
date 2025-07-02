# AutoStand Proxy Server

This proxy server handles Slack webhook calls for the AutoStand Flutter web app.

## Setup

1. Install dependencies:
```bash
cd proxy-server
npm install
```

2. Start the server:
```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

## Endpoints

- `GET /` - Health check
- `POST /api/slack/send` - Send message to Slack

## Environment Variables

You can create a `.env` file to override default settings:
- `PORT` - Server port (default: 3000)
- `SLACK_WEBHOOK_URL` - Your Slack webhook URL

## Deployment Options

### Vercel
1. Install Vercel CLI: `npm i -g vercel`
2. Run: `vercel`

### Heroku
1. Create app: `heroku create autostand-proxy`
2. Deploy: `git push heroku main`

### Local Development
The server runs on `http://localhost:3000` by default.