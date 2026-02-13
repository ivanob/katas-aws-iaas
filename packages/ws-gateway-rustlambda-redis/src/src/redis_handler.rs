use redis::Commands;
use lambda_runtime::Error;

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

    pub fn list_games(&mut self) -> Result<Vec<String>, Error> {
        let keys: Vec<String> = self.connection
            .keys("game:*")?;
        Ok(keys)
    }

    pub fn flush_db(&mut self) -> Result<(), Error> {
        self.connection.flushdb::<()>()?;
        Ok(())
    }
}