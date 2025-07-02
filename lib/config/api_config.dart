class ApiConfig {
  // For production, these should be loaded from environment variables
  // These are fallback values if .env file is not found
  
  // IMPORTANT: Add your OpenAI API key in .env file
  static const String openAIApiKey = 'your-openai-api-key-here';
  
  // Slack webhook URL for posting standup updates
  static const String slackWebhookUrl = 'your-slack-webhook-url-here';
  
  // Add other API keys as needed
  static const String anthropicApiKey = 'your-anthropic-api-key-here';
}