class ApiConfig {
  // For production, these should be loaded from environment variables
  // or a secure configuration service
  
  // IMPORTANT: Add your OpenAI API key here or in .env file
  static const String openAIApiKey = 'your-openai-api-key-here';
  
  // Slack webhook URL for posting standup updates
  static const String slackWebhookUrl = 'your-slack-webhook-url-here';
  
  // Add other API keys as needed
  static const String anthropicApiKey = 'your-anthropic-api-key-here';
}