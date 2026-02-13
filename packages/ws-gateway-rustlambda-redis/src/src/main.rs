use lambda_runtime::{service_fn, Error, LambdaEvent};
use serde_json::{json, Value};
mod redis_handler;
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
        "$default" => handle_default(&event),
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

fn handle_default(event: &Value) -> Result<Value, Error> {
    println!("Processing game action...");
    
    // Parse the message body
    let body = event["body"].as_str().unwrap_or("{}");
    let request: Value = serde_json::from_str(body).unwrap_or(json!({}));
    let user_conn_id = extract_connection_id(&event)
        .ok_or_else(|| Error::from("Missing connectionId in requestContext"))?;
    println!("Connection ID: {:?}", user_conn_id.to_string());
    
    // Extract action from message
    let action = request["action"].as_str().unwrap_or("unknown");
    
    match action {
        "list" => handle_list_games(event, &request),
        "create" => handle_create_game(event, &request, user_conn_id),
        "reset" => handle_reset_game(event, &request),
        _ => Ok(json!({ 
            "statusCode": 400,
            "body": format!("Unknown action: {}", action)
        }))
    }
}

fn handle_list_games(event: &Value, request: &Value) -> Result<Value, Error> {
    println!("Player listing games: {:?}", request);
    let mut redis = RedisHandler::connect_redis(&get_redis_url())?;
    let games = redis.list_games()?;
    println!("Games found: {:?}", games);
    Ok(json!({ 
        "statusCode": 200,
        "body": serde_json::to_string(&games)?
    }))
}

fn handle_create_game(event: &Value, request: &Value, user_conn_id: &str) -> Result<Value, Error> {
    println!("Player creating game: {:?}", request);
    let mut redis = RedisHandler::connect_redis(&get_redis_url())?;
    redis.create_game(user_conn_id)?;

    Ok(json!({ 
        "statusCode": 200,
        "body": format!("Game with ID {} created successfully!", user_conn_id)
    }))
}

fn handle_reset_game(event: &Value, request: &Value) -> Result<Value, Error> {
    println!("Resetting game: {:?}", request);
    let mut redis = RedisHandler::connect_redis(&get_redis_url())?;
    redis.flush_db()?;

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

fn handle_join_game(event: &Value, request: &Value) -> Result<Value, Error> {
    println!("Player joining game: {:?}", request);
    // let game_id = request["gameId"].as_str().unwrap_or("");
    // let mut redis = RedisHandler::connect_redis(&get_redis_url())?;
    // let game_state = redis.join_game(game_id)?;

    Ok(json!({ 
        "statusCode": 200,
        "body": "Joined game successfully!"
    }))
}