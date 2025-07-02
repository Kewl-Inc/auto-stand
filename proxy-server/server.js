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
const SLACK_WEBHOOK_URL = process.env.SLACK_WEBHOOK_URL || 'your-slack-webhook-url-here';

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

    console.log('Slack webhook URL:', SLACK_WEBHOOK_URL);
    console.log('Sending message to Slack...');

    // Send to Slack
    const response = await axios.post(SLACK_WEBHOOK_URL, {
      text: text
    });

    res.json({ success: true, message: 'Message sent to Slack' });
  } catch (error) {
    console.error('Error sending to Slack:', error.message);
    if (error.response) {
      console.error('Response status:', error.response.status);
      console.error('Response data:', error.response.data);
    }
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