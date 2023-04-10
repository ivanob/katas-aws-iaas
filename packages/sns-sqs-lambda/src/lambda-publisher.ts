import * as AWS from "aws-sdk";

const sns = new AWS.SNS({ region: "eu-west-1" });

type WeatherReading = {
  city: string,
  datetime: number,
  celsius: number
}

exports.handler = async (event) => {
  const {city, celsius} = event;
  let {datetime} = event;
  if(!city && !celsius){
    return {
      statusCode: 400,
      body: JSON.stringify({
        error: "It is missing the city or celsius parameters",
      }),
      headers: {
        "Content-Type": "application/json",
      },
    };
  }
  if(!datetime){
    datetime = Date.now();
  }
  const reading: WeatherReading = {
    city,
    celsius,
    datetime
  }
  console.log('Publisher is gonna be esecuted with reading: ', JSON.stringify(event))
  await sendNotificationMessage(reading);
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Reading delivered to SNS",
      data: reading
    }),
    headers: {
      "Content-Type": "application/json",
    },
  };
};

const sendNotificationMessage = async (reading: WeatherReading) => {
  const publishParams = {
    TopicArn: "arn:aws:sns:eu-west-1:065454142634:weather-topic",
    Message: JSON.stringify(reading), // Replace with the message you want to publish
  };
  try{
    const data = await sns.publish(publishParams).promise();
    console.log("Message published successfully: ", data);
  }catch(error){
    console.error("Failed to publish message: ", error);
  }
};
