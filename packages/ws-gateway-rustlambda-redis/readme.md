The idea of this kata is to implement a Websocket server behind AWS gateway to accept connections from 2 players
of tic-tac-toe. 2 people will be able to communicate with the server, that will store games in REDIS. The computing
piece behind the Gateway is gonna be a lambda that respond for the WS messages of all the games.
The frontend will be implemented in NextJS and deployed in AWS Amplify (no vercel or netlify).

Gateway → keeps connections open
Lambda → stateless game logic. It receives route keys from clients and performs the operations in memory (Redis)
Redis → cheap, fast, shared memory for game state

<h3>Instructions</h3>
In order to compile the rust code it is needed the package cargo-lambda
`cargo install cargo-lambda`
