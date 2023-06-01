import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { extension as getExtension } from 'es-mime-types';

const client = new S3Client({
  region: 'eu-west-1'//process.env.AWS_REGION,
});

exports.handler = async (event: any) => {  
    const uploadURL = await getUploadURL(event);
  
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
  
  const getUploadURL = async function(event: any) {
  
    const apiRequestId = '12345'; //event.requestContext.requestId || '12345';
    const contentType = 'image/jpeg'//event.queryStringParameters.contentType || 'image/jpeg'; //THis comes from the URL request like: ?contentType=image/png
    const extension = getExtension(contentType);
    const s3Key = `${apiRequestId}.${extension}`;
  
    // Get signed URL from S3
    const putObjectParams = {
      Bucket: process.env.UPLOAD_BUCKET || 'gateway-to-s3',
      Key: s3Key,
      ContentType: contentType,
    };
    const command = new PutObjectCommand(putObjectParams);
  
    const signedUrl = await getSignedUrl(client, command, { expiresIn: parseInt(process.env.URL_EXPIRATION_SECONDS || '300') });
  
    return {
      uploadURL: signedUrl,
      key: s3Key,
    };
  };