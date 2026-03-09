import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

const get_conversation = (event: APIGatewayProxyEvent): APIGatewayProxyResult => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "OK",
    }),
  };
};

const post_conversation = (event: APIGatewayProxyEvent): APIGatewayProxyResult => {
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
