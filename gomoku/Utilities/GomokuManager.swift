import Foundation
import UIKit

class GomokuManager: Board {
    var inGameController: InGameController // 매니저내에서 게임을 컨트롤하기 위해 사용됩니다.
    
    init(inGameController: InGameController, boardSize: Int, isAIFirst: Bool) {
        self.inGameController = inGameController
        super.init(boardSize: boardSize) // 새 보드판을 생성합니다.
        Minimax.isAIFirst = isAIFirst
        
        if(isAIFirst) { // 만약 AI가 선공이라면 첫번째 돌을 보드판 중앙에 놓습니다.
            let _ = putStone(i: boardSize / 2, j: boardSize / 2, stone: 1)
        }
    }
    
    // 현재 상태를 고려하여 Minimax 알고리즘을 이용해 AI의 다음 수를 계산합니다.
    private func calculateNextMove() -> [Int] {
        var nextMove = Minimax.searchWinningMove(board: board, forStone: Minimax.isAIFirst ? 1 : 2, isMax: true)
        
        if(nextMove == nil) {
            let aiMove = Minimax.search(depth: 2, board: super.getBoard(), isMax: true, forStone: Minimax.isAIFirst ? 1 : 2, alpha: -1.0, beta: Double(Minimax.getWinScore()))
            nextMove = [aiMove.1!, aiMove.2!]
        }
        
        return nextMove!
    }
    
    // 현재 상태에서 우승자가 있는지 확인합니다.
    // -> 0: 우승자 없음, 1: 황돌 우승, 2: 백돌 우승
    private func checkWinner() -> Int {
        let blackScore = Minimax.getStoneScore(board: board, forStone: 1, isMax: true)
        let whiteScore = Minimax.getStoneScore(board: board, forStone: 2, isMax: true)
        
        if(blackScore >= Minimax.getWinScore()) { return 1 }
        if(whiteScore >= Minimax.getWinScore()) { return 2 }
        return 0
    }
    
    // 보드판에 돌을 놓습니다.
    // stone: 돌 색상입니다.(1: 황, 2: 백)
    override func putStone(i: Int, j: Int, stone: Int) -> Bool {
        if(super.putStone(i: i, j: j, stone: stone)) {
            inGameController.putStone(color: stone == 1 ? 0 : 1, i: i, j: j)
            return true
        }
        return false
    }
    
    // 사용자가 돌을 놓은 후 실행되는 메서드로, AI의 다음 수를 계산합니다.
    func run() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // 백그라운드 계산을 위해 사용합니다.
            var winner = self.checkWinner() // 사용자가 돌을 놓았을 때 우승자가 발생하였는지 확인합니다.
            if(winner != 0) { // 우승자가 발생한 경우
                self.inGameController.terminateGame(message: "\(winner == 1 ? "황돌" : "백돌") 우승!")
                self.inGameController.setUserInteractive(isEnabled: false)
                return
            }
            
            let aiMove = self.calculateNextMove()
            let _ = self.putStone(i: aiMove[0], j: aiMove[1], stone: Minimax.isAIFirst ? 1 : 2)
            
            winner = self.checkWinner() // AI가 돌을 놓았을 때 우승자가 발생하였는지 확인합니다.
            if(winner != 0) { // 우승자가 발생한 경우
                self.inGameController.terminateGame(message: "\(winner == 1 ? "황돌" : "백돌") 우승!")
                self.inGameController.setUserInteractive(isEnabled: false)
                return
            }
        }
    }
}
