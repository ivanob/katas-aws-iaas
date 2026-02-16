use redis::Commands;
use lambda_runtime::Error;
use aws_sdk_apigatewaymanagement as apigatewaymanagement;
use aws_config;
use aws_smithy_types::Blob;

async fn send_message_to_client(
    connection_id: &str,
    message: &str,
) -> Result<(), Error> {
    // Get the WebSocket API endpoint from environment variable
    let endpoint = std::env::var("WS_API_ENDPOINT")
        .expect("WS_API_ENDPOINT environment variable not set");
    
    println!("Sending message to connection: {}, endpoint: {}", connection_id, endpoint);
    
    let config = aws_config::load_from_env().await;
    
    // Build custom config with the WebSocket endpoint
    let api_config = aws_sdk_apigatewaymanagement::config::Builder::from(&config)
        .endpoint_url(endpoint)
        .build();
    
    let client = aws_sdk_apigatewaymanagement::Client::from_conf(api_config);
    
    let result = client
        .post_to_connection()
        .connection_id(connection_id)
        .data(aws_smithy_types::Blob::new(message.as_bytes()))
        .send()
        .await;
    
    match result {
        Ok(_) => {
            println!("Message sent successfully to {}", connection_id);
            Ok(())
        }
        Err(e) => {
            println!("Failed to send message: {:?}", e);
            Err(Error::from(format!("Failed to send message: {}", e)))
        }
    }
}

pub struct RedisHandler {
    connection: redis::Connection,
}

impl RedisHandler {
    pub fn connect_redis(redis_url: &str) -> Result<Self, Error> {
        let client = redis::Client::open(redis_url)?;
        let connection = client.get_connection()?;
        Ok(RedisHandler { connection })
    }

    // pub async fn set_connection(&mut self, connection_id: &str) -> Result<(), Error> {
    //     self.connection
    //         .set::<_, _, ()>(format!("connection:{}", connection_id), "connected")
    //         .await?;
    //     Ok(())
    // }

    // pub async fn delete_connection(&mut self, connection_id: &str) -> Result<(), Error> {
    //     self.connection
    //         .del::<_, ()>(format!("connection:{}", connection_id))
    //         .await?;
    //     Ok(())
    // }

    pub fn create_game(&mut self, game_id: &str) -> Result<(), Error> {
        const INITIAL_STATE: &str = "{\"board\":[[0,0,0],[0,0,0],[0,0,0]],\"currentPlayer\":1}";
        self.connection
            .set::<_, _, ()>(format!("game:{}", game_id), INITIAL_STATE)?;
        Ok(())
    }

    pub fn join_game(&mut self, game_id: &str) -> Result<String, Error> {
        // let game_state = self.connection
        //     .get::<_, String>(format!("game:{}", game_id))?;
        // Ok(game_state)
        Ok("joined".to_string())
    }

    pub async fn list_games(&mut self, connection_id: &str) -> Result<Vec<String>, Error> {
        let keys: Vec<String> = self.connection
            .keys("game:*")?;
        send_message_to_client(connection_id, &format!("Games found: {:?}", keys)).await;
        Ok(keys)
    }

    pub fn flush_db(&mut self) -> Result<(), Error> {
        self.connection.flushdb::<()>()?;
        Ok(())
    }
}