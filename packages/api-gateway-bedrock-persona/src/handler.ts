import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import {
  BedrockRuntimeClient,
  ConverseCommand,
} from "@aws-sdk/client-bedrock-runtime";

const client = new BedrockRuntimeClient({
  region: "eu-west-1",
});

const command = new ConverseCommand({
  modelId: process.env.BEDROCK_MODEL_ID || "anthropic.claude-3-5-haiku-20241022",

  system: [
    {
      text: "You are a backend assistant. Always answer briefly.",
    },
  ],

  messages: [
    {
      role: "user",
      content: [
        {
          text: "Explain DynamoDB in 3 lines",
        },
      ],
    },
  ],

  inferenceConfig: {
    maxTokens: 300,
    temperature: 0.2,
    topP: 0.9,
    stopSequences: [],
  },
});

const get_conversation = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  const response = await client.send(command);
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: response.output?.message?.content,
    }),
  };
};

const post_conversation = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "OK",
    }),
  };
};

/**
 * For simplicity, I use the same lambda for both GET and POST methods.
 */
exports.handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  switch (event.httpMethod) {
    case "GET":
      return get_conversation(event);
    case "POST":
      return post_conversation(event);
    default:
      return {
        statusCode: 405,
        body: JSON.stringify({
          Error: "Only methods supported are: GET and POST",
        }),
        headers: {
          "Content-Type": "application/json",
        },
      };
  }
};
