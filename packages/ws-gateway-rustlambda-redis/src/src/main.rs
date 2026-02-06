use lambda_runtime::{service_fn, Error, LambdaEvent};
use serde_json::{json, Value};

#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_runtime::run(service_fn(handler)).await
}

async fn handler(event: LambdaEvent<Value>) -> Result<Value, Error> {
    let (event, _context) = event.into_parts();
    println!("Received event: {:?}", event);
    
    let route_key = event["requestContext"]["routeKey"]
        .as_str()
        .unwrap_or("unknown");
    
    let response = match route_key {
        "$connect" => handle_connect(&event).await?,
        "$disconnect" => handle_disconnect(&event).await?,
        "$default" => handle_default(&event).await?,
        _ => handle_unknown(&event).await?,
    };
    
    Ok(response)
}

async fn handle_connect(event: &Value) -> Result<Value, Error> {
    println!("Client connecting...");
    // TODO: Store connection ID in DynamoDB/Redis
    // let connection_id = event["requestContext"]["connectionId"].as_str();
    
    Ok(json!({ 
        "statusCode": 200,
        "body": "Connected to Tic-Tac-Toe game!"
    }))
}

async fn handle_disconnect(event: &Value) -> Result<Value, Error> {
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
    let message: Value = serde_json::from_str(body).unwrap_or(json!({}));
    
    // Extract action from message
    let action = message["action"].as_str().unwrap_or("unknown");
    
    match action {
        "list" => handle_list_games(event, &message).await,
        "create" => handle_create_game(event, &message).await,
        "reset" => handle_reset_game(event, &message).await,
        _ => Ok(json!({ 
            "statusCode": 400,
            "body": format!("Unknown action: {}", action)
        }))
    }
}

async fn handle_list_games(event: &Value, message: &Value) -> Result<Value, Error> {
    println!("Player listing games: {:?}", message);
    // TODO: Game logic - create or join a game
    // let player_name = message["playerName"].as_str();
    // let game_id = message["gameId"].as_str();
    
    Ok(json!({ 
        "statusCode": 200,
        "body": "Joined game successfully"
    }))
}

async fn handle_create_game(event: &Value, message: &Value) -> Result<Value, Error> {
    println!("Player creating game: {:?}", message);
    // TODO: Game logic - validate and process move
    // let position = message["position"].as_i64();
    // let game_id = message["gameId"].as_str();
    
    Ok(json!({ 
        "statusCode": 200,
        "body": "Move processed"
    }))
}

async fn handle_reset_game(event: &Value, message: &Value) -> Result<Value, Error> {
    println!("Resetting game: {:?}", message);
    // TODO: Game logic - reset game state
    // let game_id = message["gameId"].as_str();
    
    Ok(json!({ 
        "statusCode": 200,
        "body": "Game reset"
    }))
}

async fn handle_unknown(event: &Value) -> Result<Value, Error> {
    println!("Unknown route");
    Ok(json!({ 
        "statusCode": 400,
        "body": "Unknown route"
    }))
}