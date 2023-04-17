import { APIGatewayAuthorizerResult, APIGatewayRequestAuthorizerEvent } from 'aws-lambda';

exports.handler = async (event: APIGatewayRequestAuthorizerEvent): Promise<APIGatewayAuthorizerResult> => {
  try {
    // Validate the authorization token from the event
    const headers = event.headers!;
    const token = headers['authorization-token'];

    console.log(JSON.stringify(token))
    console.log(JSON.stringify(headers))
    // Perform your authentication logic here, e.g., validate token, check permissions, etc.
    console.log('The token received is: ', token)
    if(token !== 'ABC123'){
        throw Error('Invalid token')
    }

    // Return an IAM policy that allows or denies access to the API Gateway method
    const policy = generateIAMPolicy('user', 'Allow', event.methodArn);
    return policy;
  } catch (error) {
    console.error('Failed to authorize: ', error);
    // Return an IAM policy that denies access to the API Gateway method
    const policy = generateIAMPolicy('user', 'Deny', event.methodArn);
    return policy;
  }
};

const generateIAMPolicy = (principalId: string, effect: string, resource: string): APIGatewayAuthorizerResult => {
  const policy: APIGatewayAuthorizerResult = {
    principalId,
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: effect,
          Resource: resource
        }
      ]
    }
  };

  return policy;
};
