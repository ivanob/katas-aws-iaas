

### Goal
This is a graphql API exposing different datasources: a dynamoDB collection, some RDS tables...
The AWS service to achieve this is AWS AppSync. The idea behind graphql is to expose one single endoint that the client is gonna use with a SQL-ish language to query/store data.

AWS AppSync requires a description of the schema in graphql: how are the entities defined and how are the operations we can perform over them. If the operation is a getter it is called <b>resolver</b> and if it modifies some data in the datasource it is called <b>mutator</b>
We need to define how these resolvers and mutators are, and I define it in the resolvers.tf file. In the case of modifying the database datasource it is pretty straightforward, as it just passes the data we receive in the query, so there is no extra computation in the middle.

Another very important feature of AWS AppSync is that it can connect different datasources at the same time and serve complex queries mixing data from several of them at the same time. It can work with dynamodb, auroraDB, and lambda... so from lambda we can connect with any other AWS service really.

![](files/diagram-infra.jpg)

Using the AWS console you can query/mutate data, example:
![](files/mutator.png)
![](files/resolver.png)

### Resources
- AWS AppSync Introduction: https://www.youtube.com/watch?v=O-nr3983-ZY