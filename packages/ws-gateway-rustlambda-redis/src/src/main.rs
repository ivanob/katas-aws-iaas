use lambda_runtime::{service_fn, Error, LambdaEvent};
use serde_json::{json, Value};

#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_runtime::run(service_fn(handler)).await
}

async fn handler(event: LambdaEvent<Value>) -> Result<Value, Error> {
    let (event, _context) = event.into_parts();
    
    // Log the incoming event
    println!("Received event: {:?}", event);
    
    // Extract route key
    let route_key = event["requestContext"]["routeKey"]
        .as_str()
        .unwrap_or("unknown");
    
    // Handle different routes
    let response = match route_key {
        "$connect" => json!({ "statusCode": 200, "body": "Connected!" }),
        "$disconnect" => json!({ "statusCode": 200, "body": "Disconnected!" }),
        "$default" => json!({ "statusCode": 200, "body": "Message received!" }),
        _ => json!({ "statusCode": 400, "body": "Unknown route" }),
    };
    
    Ok(response)
}