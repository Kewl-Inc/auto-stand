const express = require('express');
const cors = require('cors');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Slack webhook URL - you can also put this in .env file
const SLACK_WEBHOOK_URL = 'https://hooks.slack.com/services/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';

// Health check endpoint
app.get('/', (req, res) => {
  res.json({ status: 'AutoStand proxy server is running' });
});

// Proxy endpoint for Slack
app.post('/api/slack/send', async (req, res) => {
  try {
    const { text } = req.body;
    
    if (!text) {
      return res.status(400).json({ error: 'Message text is required' });
    }

    // Send to Slack
    const response = await axios.post(SLACK_WEBHOOK_URL, {
      text: text
    });

    res.json({ success: true, message: 'Message sent to Slack' });
  } catch (error) {
    console.error('Error sending to Slack:', error.message);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to send message to Slack',
      details: error.message 
    });
  }
});

app.listen(PORT, () => {
  console.log(`AutoStand proxy server running on port ${PORT}`);
  console.log(`CORS enabled for all origins`);
});