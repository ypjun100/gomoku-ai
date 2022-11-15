import Foundation

class GomokuManager: Board {
    init(boardSize: Int, isAIFirst: Bool) {
        super.init(boardSize: boardSize)
        
        Minimax.isAIFirst = isAIFirst
    }
    
    func calculateNextMove(playerMoveI: Int, playerMoveJ: Int, playerStone: Int) -> [Int] {
        var nextMove = Minimax.searchWinningMove(board: board, forStone: playerStone == 1 ? 2 : 1, isMax: false)
        
        if(nextMove == nil) {
            let aiMove = Minimax.search(depth: 2, board: super.getBoard(), isMax: true, forStone: playerStone == 1 ? 2 : 1, alpha: -1.0, beta: Double(Minimax.getWinScore()))
            nextMove = [aiMove.1!, aiMove.2!]
        }
        
        return nextMove!
    }
}
