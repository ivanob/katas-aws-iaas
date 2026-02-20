<h3>Implementation of a AI persona to communicate through API gateway</h3>

Main points:
- As the AI charges per token, we will set up a limit per user in the Gateway
- Also in the Gateway we will authenticate users without cognito. Just a lambda validating that the users are from our white list.
