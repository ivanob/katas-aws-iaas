use redis::Commands;
use lambda_runtime::Error;
use aws_sdk_apigatewaymanagement as apigatewaymanagement;
use aws_config;
use aws_smithy_types::Blob;

async fn send_message_to_client(
    connection_id: &str,
    message: &str,
) -> Result<(), Error> {
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

    pub async fn create_game(&mut self, user_conn_id: &str) -> Result<(), Error> {
        let initial_state: &str = &format!("{{\"board\":[[0,0,0],[0,0,0],[0,0,0]],\"currentPlayer\":1,\"status\":\"waiting_oponent\",\"players\":[{:?}]}}", user_conn_id);
        self.connection
            .set::<_, _, ()>(format!("game:{}", user_conn_id), initial_state)?;
        send_message_to_client(user_conn_id, &format!("Game created: {:?}", user_conn_id)).await;
        Ok(())
    }

    pub async fn join_game(&mut self, game_id: &str, user_conn_id: &str) -> Result<String, Error> {
        let game_state_str: String = self.connection
            .get(format!("game:{}", game_id))?;
        let mut game_state: serde_json::Value = serde_json::from_str(&game_state_str)?;
        if game_state["status"] == "waiting_oponent" {
            if let Some(players) = game_state["players"].as_array_mut() {
                players.push(serde_json::json!(user_conn_id));
            }
            game_state["status"] = serde_json::json!("in_progress");
            // Save the modified state back to Redis
            let updated_state = serde_json::to_string(&game_state)?;
            self.connection.set::<_, _, ()>(format!("game:{}", game_id), updated_state)?;
            send_message_to_client(game_id, &format!("Joined sucessfully to game {}", game_id)).await?;
        } else {
            send_message_to_client(game_id, &format!("Game: {} not found or maybe it is already full", game_id)).await?;
        }
        println!("Game state for {}: {}", game_id, game_state);
        Ok("joined".to_string())
    }

    pub async fn list_games(&mut self, connection_id: &str) -> Result<Vec<String>, Error> {
        let keys: Vec<String> = self.connection
            .keys("game:*")?;
        send_message_to_client(connection_id, &format!("Games found: {:?}", keys)).await;
        Ok(keys)
    }

    pub async fn flush_db(&mut self) -> Result<(), Error> {
        self.connection.flushdb::<()>()?;
        Ok(())
    }

    pub async fn debug_db(&mut self, connection_id: &str) -> Result<(), Error> {
        let keys: Vec<String> = self.connection.keys("*")?;
        println!("Total keys found: {}", keys.len());
        for key in &keys {
            let value: String = self.connection.get(key)?;
            println!("Key: {} => Value: {}", key, value);
            send_message_to_client(connection_id, &format!("Key: {} => Value: {}", key, value)).await;
        }
        Ok(())
    }

    pub async fn make_move(&mut self, game_id: &str, x: usize, y: usize, player_id: &str) -> Result<(), Error> {
        let game_state_str: String = self.connection
            .get(format!("game:{}", game_id))?;
        let mut game_state: serde_json::Value = serde_json::from_str(&game_state_str)?;
        
        if game_state["status"] == "in_progress" {
            if let Some(board) = game_state["board"].as_array_mut() {
                if board[y][x] == 0 {
                    let current_player = game_state["currentPlayer"].as_u64().unwrap_or(1);
                    board[y][x] = (current_player as i64).into();
                    // Switch player
                    game_state["currentPlayer"] = serde_json::json!(if current_player == 1 { 2 } else { 1 });
                    // Save the modified state back to Redis
                    let updated_state = serde_json::to_string(&game_state)?;
                    self.connection.set::<_, _, ()>(format!("game:{}", game_id), updated_state)?;
                    send_message_to_client(game_id, &format!("Move made at ({}, {}) by player {}", x, y, player_id)).await?;
                } else {
                    send_message_to_client(game_id, &format!("Invalid move at ({}, {}) - cell already occupied", x, y)).await?;
                }
            }
        } else {
            send_message_to_client(game_id, "Game not in progress").await?;
        }
        println!("Game state for {}: {}", game_id, game_state);
        Ok(())
    }
}