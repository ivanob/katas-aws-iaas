

# Goal
The goal is to create an API to upload/download files (images, documents...) to S3. To do this, I will be using presigned URLs which is the most recommended way in AWS. A presigned URL is a temporary usable URL that the client can use to perform that upload or download without having to declare public the s3 bucket.
So every time the client needs to transfer a document there will be 2 steps:
 - Request a presigned URL
 - Use that URL to send/receive the file
As described below, the architecture will be:
 - An API-gateway to expose the endpoints to the exterior
 - A lambda signer that will request the presigned URLs to S3 every time the client requests
 - The S3 itself
I wont be implementing any authentication here, but in real life would be a good idea to protect the gateway with some kind of authentication/authorization so its not open to everybody.

# Architecture

[[ PUT HERE A DIAGRAM ]]

### References

- https://aws.amazon.com/blogs/compute/uploading-to-amazon-s3-directly-from-a-web-or-mobile-application/
- https://docs.aws.amazon.com/apigateway/latest/developerguide/integrating-api-with-aws-services-s3.html
- https://github.com/aws-samples/serverless-patterns/tree/main/s3-upload-presignedurl-api-cdk-ts
- https://github.com/jeromevdl/cdk-s3-upload-presignedurl-api
- https://www.radishlogic.com/aws/s3/minimum-iam-permission-to-create-s3-presigned-urls/
- https://medium.com/@aidan.hallett/securing-aws-s3-uploads-using-presigned-urls-aa821c13ae8d
- Why I am receiving a 403 forbidden: https://medium.com/@lakshmanLD/upload-file-to-s3-using-lambda-the-pre-signed-url-way-158f074cda6c