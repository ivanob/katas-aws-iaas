use serde_json::{json, Value};

pub struct TicTacToeEngine;

impl TicTacToeEngine {
    /// Create a new game state as JSON string
    pub fn new(id_first_player: &str) -> String {
        let initial_state = json!({
            "board": [[0, 0, 0], [0, 0, 0], [0, 0, 0]],
            "currentPlayer": 1,
            "status": "waiting_oponent",
            "players": [id_first_player]
        });
        serde_json::to_string(&initial_state).unwrap()
    }

    /// Join an existing game (add second player)
    pub fn join_game(game_state_str: String, user_conn_id: &str) -> Result<String, String> {
        let mut game_state: Value = serde_json::from_str(&game_state_str)
            .map_err(|e| format!("Invalid JSON: {}", e))?;

        if game_state["status"] == "waiting_oponent" {
            if let Some(players) = game_state["players"].as_array_mut() {
                players.push(json!(user_conn_id));
            }
            game_state["status"] = json!("in_progress");
            serde_json::to_string(&game_state)
                .map_err(|e| format!("Failed to serialize: {}", e))
        } else {
            Err("Game is not waiting for opponent".to_string())
        }
    }

    /// Make a move on the board
    pub fn make_move(game_state_str: String, row: usize, col: usize, player: i32) -> Result<String, String> {
        let mut game_state: Value = serde_json::from_str(&game_state_str)
            .map_err(|e| format!("Invalid JSON: {}", e))?;

        // Validate move
        if row >= 3 || col >= 3 {
            return Err("Move out of bounds".to_string());
        }

        // Get board and check if cell is empty
        if let Some(board) = game_state["board"].as_array_mut() {
            if let Some(row_arr) = board[row].as_array_mut() {
                if row_arr[col].as_i64().unwrap_or(0) != 0 {
                    return Err("Cell already occupied".to_string());
                }
                row_arr[col] = json!(player);
            }
        }

        // Switch player
        game_state["currentPlayer"] = json!(if player == 1 { 2 } else { 1 });

        // TODO: Check for win/draw

        serde_json::to_string(&game_state)
            .map_err(|e| format!("Failed to serialize: {}", e))
    }
}