import { generateText, gateway } from 'ai';

// Vercel AI Gateway: model string is `<provider>/<model>`,
// auth comes from the AI_GATEWAY_API_KEY environment variable.
// Override with AI_MODEL, e.g. AI_MODEL=poolside/laguna-s-2.1-free node index.mts
const model = gateway(process.env.AI_MODEL ?? 'openai/gpt-5.6-sol');

const result = await generateText({
  model,
  prompt: 'Say hello and briefly describe what you are, in exactly two sentences.',
});

console.log(result.text);
