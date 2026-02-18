use lambda_runtime::{service_fn, Error, LambdaEvent};
use serde_json::{json, Value};
mod redis_handler;
mod tictactoe_engine;
use redis_handler::RedisHandler;

#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_runtime::run(service_fn(handler)).await
}

fn get_redis_url() -> String {
    std::env::var("REDIS_URL").unwrap_or_else(|_| "redis://127.0.0.1:6379".to_string())
}

fn extract_connection_id(event: &Value) -> Option<&str> {
    event
        .get("requestContext")?
        .get("connectionId")?
        .as_str()
}

async fn handler(event: LambdaEvent<Value>) -> Result<Value, Error> {
    let (event, _context) = event.into_parts();
    println!("Received event: {:?}", event);
    
    let route_key = event["requestContext"]["routeKey"]
        .as_str()
        .unwrap_or("unknown");
    
    let response = match route_key {
        "$connect" => handle_connect(&event),
        "$disconnect" => handle_disconnect(&event),
        "$default" => handle_default(&event).await,
        _ => handle_unknown(&event),
    };
    println!("Response: {:?}", response);
    Ok(response?)
}

fn handle_connect(event: &Value) -> Result<Value, Error> {
    println!("Client connecting...");
    // TODO: Store connection ID in DynamoDB/Redis
    // let connection_id = event["requestContext"]["connectionId"].as_str();
    
    Ok(json!({ 
        "statusCode": 200,
        "body": "Connected to Tic-Tac-Toe game!"
    }))
}

fn handle_disconnect(event: &Value) -> Result<Value, Error> {
    println!("Client disconnecting...");
    // TODO: Remove connection ID from DynamoDB/Redis
    // let connection_id = event["requestContext"]["connectionId"].as_str();
    
    Ok(json!({ 
        "statusCode": 200,
        "body": "Disconnected"
    }))
}

async fn handle_default(event: &Value) -> Result<Value, Error> {
    println!("Processing game action...");
    
    // Parse the message body
    let body = event["body"].as_str().unwrap_or("{}");
    let request: Value = serde_json::from_str(body).unwrap_or(json!({}));
    let user_conn_id = extract_connection_id(&event)
        .ok_or_else(|| Error::from("Missing connectionId in requestContext"))?;
    let mut redis = RedisHandler::connect_redis(&get_redis_url())?;
    println!("Connection ID: {:?}", user_conn_id.to_string());
    
    // Extract action from message
    let action = request["action"].as_str().unwrap_or("unknown");
    
    match action {
        "list" => {
            println!("Player listing games");
            handle_list_games(user_conn_id, &mut redis).await
        },
        "create" => {
            println!("Player creating game: {:?}", request);
            handle_create_game(user_conn_id, &mut redis).await
        },
        "reset" => {
            println!("Resetting game: {:?}", request);
            handle_reset_game(&mut redis).await
        },
        "join" => {
            let id = request["id"].as_str().unwrap_or("unknown");
            println!("Joining game: {:?}", request);
            handle_join_game(id, user_conn_id, &mut redis).await
        },
        "move" => {
            println!("Player making move: {:?}", request);
            let id = request["id"].as_str().unwrap_or("unknown");
            let x_str = request["row"].as_str().unwrap_or("unknown");
            let x_usize = x_str.parse().unwrap_or(0);
            let y_str = request["col"].as_str().unwrap_or("unknown");
            let y_usize = y_str.parse().unwrap_or(0);
            println!("Move details - Row: {}, Col: {}, Player: {}", x_usize, y_usize, user_conn_id);
            redis.make_move(id, x_usize, y_usize, user_conn_id).await?;
            Ok(json!({ 
                "statusCode": 200,
                "body": "Move executed successfully!"
            }))
        }
        "debug" => {
            println!("Debugging Redis DB");
            redis.debug_db(user_conn_id).await?;
            Ok(json!({ 
                "statusCode": 200,
                "body": "Debugged Redis DB"
            }))
        },
        _ => Ok(json!({ 
            "statusCode": 400,
            "body": format!("Unknown action: {}", action)
        }))
    }
}

async fn handle_list_games(user_conn_id: &str, redis: &mut RedisHandler) -> Result<Value, Error> {
    // let games = redis.list_games(user_conn_id).await?;
    let games = "";
    Ok(json!({  // This OK message goes to the Gateway, not to the client on the other end of the WS!!
        // To send a message to the client I have to use the send_message_to_client(...) function.
        "statusCode": 200,
        "body": serde_json::to_string(&games)?
    }))
}

async fn handle_create_game(user_conn_id: &str, redis: &mut RedisHandler) -> Result<Value, Error> {
    redis.create_game(user_conn_id).await?;
    Ok(json!({ 
        "statusCode": 200,
        "body": format!("Game with ID {} created successfully!", user_conn_id)
    }))
}

async fn handle_reset_game(redis: &mut RedisHandler) -> Result<Value, Error> {
    redis.flush_db().await?;
    Ok(json!({ 
        "statusCode": 200,
        "body": "Game reset"
    }))
}

fn handle_unknown(event: &Value) -> Result<Value, Error> {
    println!("Unknown route");
    Ok(json!({ 
        "statusCode": 400,
        "body": "Unknown route"
    }))
}

async fn handle_join_game(game_id: &str, user_conn_id: &str, redis: &mut RedisHandler) -> Result<Value, Error> {
    let game_state = redis.join_game(game_id, user_conn_id).await?;

    Ok(json!({ 
        "statusCode": 200,
        "body": "Joined game successfully!"
    }))
}