
### Goals
- [ ] Implement a SNS => SQS architecture with lambdas listening at the end of each queue.
- [ ] Logging: set up a logging system and try to centralise
- [ ] Graphic architecture tool to create diagrams
- [ ] Investigate how to set N lambda instances listening at the same SQS in case it needs to scale up horizontally
- [ ] Create via terraform a cloudwatch monitor
 
### Description
A lambda will publish directly to a SNS queue that will fan out the message
to several different SQS, and we will have a lambda listening after each of them.
The message delivered is gonna be the weather in a specific town (nameCity, datetime, celsius).



### Bibliography
- SNS vs SQS vs EventBridge: https://www.youtube.com/watch?v=RoKAEzdcr7k