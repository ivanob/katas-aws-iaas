# katas-aws-iac

A collection of notes, resources, documentation and POCs mainly related to AWS Infrastructure as code (IaC). The final goal is learning purposes and quick prototyping to prove concepts and test designs.

# Scenarios
Here it goes the list of scenarios I have created and a brief description:

 - [X] api-gateway-lambda
 - [X] api-gateway-lambda-auth
 - [X] sns-sqs-lambda
 - [X] static-s3-cloudfront
 - [X] Upload documents via gateway + S3: api-gateway-upload-file-s3
 - [X] Graphql in api gateway
 - [X] ALB (ELB) to ECS with Fargate tasks (instead of EC2)
 - [X] Websocket implementation with api gateway and lambdas (Rust) + Memcached (Redis) storage. (Tic-Tac-Toe)
 - [ ] Bedrock
 - [ ] Deployment of frontend in Amplify (NextJS). Frontend for Tic-tac-toe game
 - [ ] Eventbridge. Implementation of CQRS
 - [ ] Eventbridge vs SNS. Filtering vs routing.
 - [ ] Kafka. Implementation of CQRS.
 - [ ] SSO -> Single Sign On. frontend with 2 different domains sharing the same login credentials
 - [ ] gRPC protocol
 - [ ] ECS Elastic Cloud Storage
 - [ ] Step functions implementation
 - [ ] EC2 connected to several AWS services via software: gateway, sns, sqs...
 - [ ] Automatizar el despliegue de un ec2 desde que hago el push al ecr, usando codebuild o github actions
 - [ ] La kata definitiva. Meterle mano a EKS
 - [ ] Desplegar dos microservices que trabajan together en ec2 y que se sincronicen. Eks? Ecs? Integrado con CICD
 - [ ] Ec2 integrado con cognito
 - [ ] Cognito hosted. 2 domains with two frontends using SSO. Find a way to do this
 - [ ] Cached responses with AWS gateway. Invalidate caches, different caching policies...


# Dismissed

 - [X] Authentication via Cognito
    - Done in TKS project
 - [ ] Scenario of failure and recovery in queue + lambda
 - [X] How to deploy a big API from EC2 and open it to the internet, Can be implemented in nest.js, and swagger? VS API Gateway
    - Done in previous scenarios
 - [X] Secret management from a lambda
    - Done in TKS project
 - [X] Hacer kata aws generar swagger desde api-gateway
    - Done in TKS project
 - [ ] Integration with grafana
 - [X] Associate api-gateway with route53 to link a domain name
    - Done in TKS project