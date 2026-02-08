use redis::AsyncCommands;
use lambda_runtime::Error;

pub struct RedisHandler {
    connection: redis::aio::MultiplexedConnection,
}

impl RedisHandler {
    pub async fn connect_redis(redis_url: &str) -> Result<Self, Error> {
        let client = redis::Client::open(redis_url)?;
        let connection = client.get_multiplexed_async_connection().await?;
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

    pub async fn create_game(&mut self, game_id: &str) -> Result<(), Error> {
        const initial_state = "{\"board\":[[0,0,0],[0,0,0],[0,0,0]],\"currentPlayer\":1}";
        self.connection
            .set::<_, _, ()>(format!("game:{}", game_id), initial_state)
            .await?;
        Ok(())
    }

    pub async fn join_game(&mut self, game_id: &str) -> Result<String, Error> {
        let game_state = self.connection
            .get::<_, String>(format!("game:{}", game_id))
            .await?;
        Ok(game_state)
    }

    pub async fn list_games(&mut self) -> Result<Vec<String>, Error> {
        let keys: Vec<String> = self.connection
            .keys("game:*")
            .await?;
        Ok(keys)
    }
}