<h3>Implementation of a AI persona to communicate through API gateway</h3>

Main points:
- Gateway exposes an endpoint to talk to a specific persona that is invented for this kata: Napoleon, Bill gates...
- User can start a conversation with any of these personas. Then, for each message from the user the persona will reply and
iteratively user can keep sending messages. It will be a rest communication for simplicity.
- 

Desirable:
- As the AI charges per token, we will set up a limit per user in the Gateway
- Also in the Gateway we will authenticate users without cognito. Just a lambda validating that the users are from our white list.
