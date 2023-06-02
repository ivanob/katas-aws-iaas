import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { extension as getExtension } from 'es-mime-types';
import { APIGatewayProxyEvent } from 'aws-lambda';

const client = new S3Client({
  region: 'eu-west-1'//process.env.AWS_REGION,
});

type FileDescription = {
  filename: string,
  contentType: string
}

exports.handler = async (event: APIGatewayProxyEvent) => {
    const filename = event.queryStringParameters?.filename;
    const contentType = event.queryStringParameters?.['content-type'];
    if(!filename || !contentType){
      return {
        statusCode: 400,
        body: JSON.stringify({message: "Bad request. The string query parameters of the GET should contain" +
        "'filename' and 'content-type'. Example: http://..../?filename=myphoto&content-type=image/jpeg"}),
      }
    }
    const uploadURL = await getUploadURL({filename, contentType});
  
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Headers': 'Authorization, *',
        'Access-Control-Allow-Origin': process.env.ALLOWED_ORIGIN || '*',
        'Access-Control-Allow-Methods': 'OPTIONS,GET',
      },
      body: JSON.stringify(uploadURL),
    };
  };
  
  const getUploadURL = async function(file: FileDescription) {
    const extension = getExtension(file.contentType);
    const s3Key = `${file.filename}.${extension}`;
  
    // Get signed URL from S3
    const putObjectParams = {
      Bucket: process.env.UPLOAD_BUCKET || 'gateway-to-s3',
      Key: s3Key,
      ContentType: file.contentType,
    };
    const command = new PutObjectCommand(putObjectParams);
  
    const signedUrl = await getSignedUrl(client, command, { expiresIn: parseInt(process.env.URL_EXPIRATION_SECONDS || '300') });
  
    return {
      uploadURL: signedUrl,
      key: s3Key,
    };
  };