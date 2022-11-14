import Foundation

class GomokuManager {
    let board: Board = Board(boardSize: 15)
    
    var isAIFirst: Bool
    
    init(isAIFirst: Bool) {
        self.isAIFirst = isAIFirst
    }
}
