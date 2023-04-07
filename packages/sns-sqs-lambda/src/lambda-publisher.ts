import * as AWS from "aws-sdk";
import dotenv from 'dotenv';

dotenv.config();
const sns = new AWS.SNS({ region: "eu-west-1" });

exports.handler = async (event) => {
  console.log('Enters')
  await sendNotificationMessage();
  return {
    statusCode: 200,
    body: JSON.stringify({
      Error: "All good",
    }),
    headers: {
      "Content-Type": "application/json",
    },
  };
};

const sendNotificationMessage = async () => {
  const publishParams = {
    TopicArn: `arn:aws:sns:us-east-1:${process.env.AWS_ACCOUNT_ID}:${process.env.TOPIC_NAME}`,
    Message: "Hello from Lambda!", // Replace with the message you want to publish
  };
  try{
    const data = await sns.publish(publishParams).promise();
    console.log("Message published successfully:", data);
  }catch(error){
    console.error("Failed to publish message:", error);
  }
};