import Foundation

// 미니맥스 알고리즘
class Minimax {
    static let winScore = 100000000 // 승리 점수. 게임에서 이기기 위해선 winScore 이상의 점수를 받아야합니다.
    public static var isAIFirst = false
    
    static func getWinScore() -> Int { return winScore }
    
    // 다음 수를 찾기 위한 미니맥스 알고리즘입니다.
    // depth: 탐색할 범위입니다. 초기 depth는 짝수이어야 합니다.
    // isMax: 미니맥스 알고리즘이 최대값을 계산할지 여부를 결정합니다.
    // stoneColor: 현재 상태의 돌 색상입니다.(1: 흑, 2: 백)
    static func search(depth: Int, board: Board, isMax: Bool, forStone: Int, alpha: Double, beta: Double) -> (Double, Int?, Int?) {
        if(depth == 0) { // 현재 상태의 최종 결과 점수를 반환합니다.
            return (getScore(board: board.getBoardArray(), isMax: !isMax), nil, nil) // 현재 상태가 아닌 이전 상태를 기준으로 점수를 계산해야하기 때문에 forStone과 isMax의 값을 반전시킵니다.
        }
        
        let possibleMoves = board.generateMoves()
        
        if(possibleMoves.count == 0) { // 만약 착수가능한 지점이 없다면 더이상 돌을 놓을 수 없다고 판단하고 최종 결과 점수를 반환합니다.
            return (getScore(board: board.getBoardArray(), isMax: !isMax), nil, nil) // 현재 상태가 아닌 이전 상태를 기준으로 점수를 계산해야하기 때문에 forStone과 isMax의 값을 반전시킵니다.
        }
        
        var bestMove: (Double, Int?, Int?) = (-1, possibleMoves[0][0], possibleMoves[0][1]) // 최종적으로 forStone 색상의 돌이 놓을 지점의 점수와 위치가 저장됩니다.
        var alpha = alpha // 알파-베타 가지치기를 위한 변수입니다.
        var beta = beta // 알파-베타 가지치기를 위한 변수입니다.
        if(isMax) { // 최대값 계산, AI가 최대한의 이득을 취할 수 있도록 합니다.
            for move in possibleMoves {
                let tmpBoard = Board(board: board.getBoardArray())
                let _ = tmpBoard.putStone(i: move[0], j: move[1], stone: forStone)
                let tmpMove = search(depth: depth - 1, board: tmpBoard, isMax: !isMax, forStone: forStone == 1 ? 2 : 1, alpha: alpha, beta: beta)
                
                // 알파-베타 가지치기
                if(tmpMove.0 > alpha) {
                    alpha = tmpMove.0
                }
                if(tmpMove.0 >= beta) {
                    return tmpMove
                }
                
                if(tmpMove.0 > bestMove.0) {
                    bestMove = (tmpMove.0, move[0], move[1])
                }
            }
        } else { // 최소값 계산, 플레이어가 최소의 이득을 얻을 수 있도록 합니다.
            bestMove.0 = Double(winScore * 2)
            for move in possibleMoves {
                let tmpBoard = Board(board: board.getBoardArray())
                let _ = tmpBoard.putStone(i: move[0], j: move[1], stone: forStone)
                let tmpMove = search(depth: depth - 1, board: tmpBoard, isMax: !isMax, forStone: forStone == 1 ? 2 : 1, alpha: alpha, beta: beta)
                
                // 알파-베타 가지치기
                if(tmpMove.0 < beta) {
                    beta = tmpMove.0
                }
                if(tmpMove.0 <= alpha) {
                    return tmpMove
                }
                
                if(tmpMove.0 <= bestMove.0) {
                    bestMove = (tmpMove.0, move[0], move[1])
                }
            }
        }
        
        return bestMove
    }
    
    // 특정 색상의 돌을 놓았을 때 바로 끝낼 수 있는 위치가 있는지 확인합니다.
    // stoneColor: 현재 상태의 돌 색상입니다.(1: 흑, 2: 백)
    static func searchWinningMove(board: Board, forStone: Int, isMax: Bool) -> [Int]? {
        let tmpBoard = Board(board: board.getBoardArray())
        let possibleMoves = tmpBoard.generateMoves()
        
        for move in possibleMoves {
            if(tmpBoard.putStone(i: move[0], j: move[1], stone: forStone)) {
                if(getStoneScore(board: tmpBoard.getBoardArray(), forStone: forStone, isMax: isMax) >= winScore) { // 만약 특정 위치에 돌을 놓았을 때의 점수가 winScore 즉, 이기기 위해서 받아야하는 점수보다 크거나 같다면 바로 끝낼 수 있는 수가 있다고 판단하고 해당 수를 반환합니다.
                    return move
                }
                tmpBoard.removeStone(i: move[0], j: move[1])
            }
        }
        return nil
    }
    
    // 보드의 상대적인 점수를 계산합니다.
    // 미니맥스 알고리즘에 사용할 점수를 매기기 위해서는 흑돌 혹은 백돌의 점수만 매기는 것이 아닌,
    // 흑돌과 백돌의 상대적인 점수를 계산해야 만약 상대의 수가 더 이득일 경우 최소의 값이 나오게 하여
    // 최대값(AI가 이득인 상황)을 찾을 때 해당 수를 거를 수 있도록 만듭니다.
    //
    // 만약, depth가 2이고, 사람이 흑돌을 취한다고 했을 때 '흑 -> 백(Max) -> 흑(Min)'의 순서를 가지며,
    // '백돌 / 흑돌'로 최종 점수를 계산하여, 흑돌(사람)이 현재 상태에서 백돌(AI)보다 더 많은 이득을 취한다고 하면
    // 최종적인 점수는 1보다 작은 수가 나와 백돌을 계산할 때 즉, 최대값을 계산할 때 제외가 되도록 합니다.
    // 반대로, depth가 2이고, AI가 흑돌을 취한다고 했을 때 '흑(Max) -> 백(Min)'의 순서를 가지며,
    // '흑돌 / 백돌'로 위와 동일하게 상대적인 최종점수를 계산합니다.
    static func getScore(board: [[Int]], isMax: Bool) -> Double {
        if(isAIFirst) { // AI가 먼저 돌을 두는 경우
            let blackScore = getStoneScore(board: board, forStone: 1, isMax: !isMax) // 주석 추가
            var whiteScore = getStoneScore(board: board, forStone: 2, isMax: !isMax) // 주석 추가
            
            if(whiteScore == 0) { whiteScore = 1 } // 주석 추가
            
            return Double(blackScore) / Double(whiteScore)
        } else { // 플레이어가 먼저 돌을 두는 경우
            var blackScore = getStoneScore(board: board, forStone: 1, isMax: isMax) // 주석 추가
            let whiteScore = getStoneScore(board: board, forStone: 2, isMax: isMax) // 주석 추가
            
            if(blackScore == 0) { blackScore = 1 } // 주석 추가
            
            return Double(whiteScore) / Double(blackScore)
        }
    }
    
    // 가로, 세로, 대각선상에 존재하는 흑돌 혹은 백돌의 합산 점수를 냅니다.
    // stoneColor: 현재 상태의 돌 색상입니다.(1: 흑, 2: 백)
    static func getStoneScore(board: [[Int]], forStone: Int, isMax: Bool) -> Int {
        return searchHorizontal(board: board, forStone: forStone, isMax: isMax) + // 가로
            searchVertical(board: board, forStone: forStone, isMax: isMax) + // 세로
            searchDiagonal(board: board, forStone: forStone, isMax: isMax) // 대각선
    }
    
    // 흑돌 혹은 백돌에 대해 가로로 연속된 돌을 찾습니다.
    // 만약 연속된 돌이 있다면, 몇 개가 연속되어 있는지 확인 후 getStoneSetScore()로 결과값을 보내
    // 해당 연속된 돌의 점수를 얻습니다.
    // stoneColor: 현재 상태의 돌 색상입니다.(1: 흑, 2: 백)
    // isMax: getStoneSetScore()에서 사용되는 파라미터입니다.
    static func searchHorizontal(board: [[Int]], forStone: Int, isMax: Bool) -> Int {
        let boardSize = board.count
        var score = 0 // 총합 점수
        var stoneCounter = 0 // 연속된 돌을 세기위한 카운터 변수
        var blockCounter = 2 // 연속된 돌이 막혀있는지 확인하기 위한 변수. 0: 연속된 돌의 양쪽이 비어있음, 1: 연속된 돌에서 좌측 혹은 우측만 비어있음, 2: 연속된 돌의 양쪽이 막혀있음.
        
        for i in 0 ..< boardSize {
            for j in 0 ..< boardSize {
                if(board[i][j] == forStone) { // 만약 forStone과 동일한 돌이 가로로 연속하여 있다면 카운터를 증가시킵니다.
                    stoneCounter += 1
                    
                } else if(board[i][j] == 0) { // 만약 현재 자리가 비었다면, 연속된 돌의 시작점 혹은 끝점으로 봅니다.
                    if(stoneCounter > 0) { // stoneCounter가 1 이상이면 이전에 forStone 색상의 돌이 있었다는 의미로 해당 돌들에 대한 점수를 매깁니다.
                        blockCounter -= 1 // 현재 자리가 비어있으므로 해당 변수를 -1 시킵니다.
                        
                        score += getStoneSetScore(count: stoneCounter, blocks: blockCounter, isMax: isMax)
                        
                        stoneCounter = 0 // 연속된 돌을 다시 처음부터 세기위해 변수를 초기화 시킵니다.
                    }
                    blockCounter = 1 // 현재 지점이 비어있는 상태이므로 나머지 한쪽이 비어있으면 0, 비어있지 않으면 2가 되기 위해 해당 변수를 1로 설정합니다.
                    
                } else { // 만약 현재 자리가 다른 돌에 의해 차지되어 있는 경우입니다.
                    if(stoneCounter > 0) { // stoneCounter가 1 이상이면 이전에 forStone 색상의 돌이 있었다는 의미로 해당 돌들에 대한 점수를 매깁니다.
                        score += getStoneSetScore(count: stoneCounter, blocks: blockCounter, isMax: isMax)
                        
                        // 연속된 돌을 다시 처음부터 세기위해 변수를 초기화 시킵니다.
                        stoneCounter = 0
                        blockCounter = 2
                    }
                }
            }
            
            if(stoneCounter >= 2) { // 한 열에 대해 탐색 과정이 끝났다면, 끝나기 직전에 연속된 돌들이 있었는지 확인하고 점수를 매깁니다.
                score += getStoneSetScore(count: stoneCounter, blocks: blockCounter, isMax: isMax)
            }
            
            // 변수들을 초기화 합니다.
            stoneCounter = 0
            blockCounter = 2
        }
        
        return score
    }
    
    // 흑돌 혹은 백돌에 대해 세로로 연속된 돌을 찾습니다.
    // 만약 연속된 돌이 있다면, 몇 개가 연속되어 있는지 확인 후 getStoneSetScore()로 결과값을 보내
    // 해당 연속된 돌의 점수를 얻습니다.
    // stoneColor: 현재 상태의 돌 색상입니다.(1: 흑, 2: 백)
    // isMax: getStoneSetScore()에서 사용되는 파라미터입니다.
    static func searchVertical(board: [[Int]], forStone: Int, isMax: Bool) -> Int {
        let boardSize = board.count
        var score = 0 // 총합 점수
        var stoneCounter = 0 // 연속된 돌을 세기위한 카운터 변수
        var blockCounter = 2 // 연속된 돌이 막혀있는지 확인하기 위한 변수. 0: 연속된 돌의 양쪽이 비어있음, 1: 연속된 돌에서 위 혹은 아래만 비어있음, 2: 연속된 돌의 양쪽이 막혀있음.
        
        for j in 0 ..< boardSize {
            for i in 0 ..< boardSize {
                if(board[i][j] == forStone) {
                    stoneCounter += 1 // 만약 forStone과 동일한 돌이 세로로 연속하여 있다면 카운터를 증가시킵니다.
                    
                } else if(board[i][j] == 0) { // 만약 현재 자리가 비었다면, 연속된 돌의 시작점 혹은 끝점으로 봅니다.
                    if(stoneCounter > 0) { // stoneCounter가 1 이상이면 이전에 forStone 색상의 돌이 있었다는 의미로 해당 돌들에 대한 점수를 매깁니다.
                        blockCounter -= 1 // 현재 자리가 비어있으므로 해당 변수를 -1 시킵니다.
                        
                        score += getStoneSetScore(count: stoneCounter, blocks: blockCounter, isMax: isMax)
                        
                        stoneCounter = 0 // 연속된 돌을 다시 처음부터 세기위해 변수를 초기화 시킵니다.
                    }
                    blockCounter = 1 // 현재 지점이 비어있는 상태이므로 나머지 한쪽이 비어있으면 0, 비어있지 않으면 2가 되기 위해 해당 변수를 1로 설정합니다.
                } else { // 만약 현재 자리가 다른 돌에 의해 차지되어 있는 경우입니다.
                    if(stoneCounter > 0) { // stoneCounter가 1 이상이면 이전에 forStone 색상의 돌이 있었다는 의미로 해당 돌들에 대한 점수를 매깁니다.
                        score += getStoneSetScore(count: stoneCounter, blocks: blockCounter, isMax: isMax)
                        
                        // 연속된 돌을 다시 처음부터 세기위해 변수를 초기화 시킵니다.
                        stoneCounter = 0
                        blockCounter = 2
                    }
                }
            }
            
            if(stoneCounter >= 2) {  // 한 열에 대해 탐색 과정이 끝났다면, 끝나기 직전에 연속된 돌들이 있었는지 확인하고 점수를 매깁니다.
                score += getStoneSetScore(count: stoneCounter, blocks: blockCounter, isMax: isMax)
            }
            
            // 변수들을 초기화 합니다.
            stoneCounter = 0
            blockCounter = 2
        }
        
        return score
    }
    
    // 흑돌 혹은 백돌에 대해 대각선으로 연속된 돌을 찾습니다.
    // 만약 연속된 돌이 있다면, 몇 개가 연속되어 있는지 확인 후 getStoneSetScore()로 결과값을 보내서
    // 해당 연속된 돌의 점수를 얻습니다.
    // stoneColor: 현재 상태의 돌 색상입니다.(1: 흑, 2: 백)
    // isMax: getStoneSetScore()에서 사용되는 파라미터입니다.
    static func searchDiagonal(board: [[Int]], forStone: Int, isMax: Bool) -> Int {
        let boardSize = board.count
        var score = 0 // 총합 점수
        var stoneCounter = 0 // 연속된 돌을 세기위한 카운터 변수
        var blockCounter = 2 // 연속된 돌이 막혀있는지 확인하기 위한 변수. 0: 연속된 돌의 양쪽이 비어있음, 1: 연속된 돌에서 위 혹은 아래만 비어있음, 2: 연속된 돌의 양쪽이 막혀있음.
        
        // 대각선은 상단 좌측에서 하단 우측으로 구성된 대각선, 상단 우측에서 하단 좌측으로 구성된 대각선이 존재하므로 두 경우에 대한 점수를 계산합니다.
        // 상단 좌측에서 하단 우측으로 구성된 대각선을 탐색합니다.
        for j in (boardSize - 5) * -1 ..< boardSize - 4 { // 최대로 가질 수 있는 대각선의 연속된 돌이 5개 이상인 경우만 계산합니다.
            for i in 0 ..< boardSize {
                if(j + i < 0 || j + i >= boardSize) { // 보드판의 사이즈를 넘지 않을 경우 건너뜁니다.
                    continue
                }
                
                if(board[i][j + i] == forStone) { // 만약 연속된 돌이 있다면 카운터를 증가시킵니다.
                    stoneCounter += 1
                    
                } else if(board[i][j + i] == 0) { // 만약 현재 자리가 비었다면, 연속된 돌의 시작점 혹은 끝점으로 봅니다.
                    if(stoneCounter > 0) { // stoneCounter가 1 이상이면 이전에 forStone 색상의 돌이 있었다는 의미로 해당 돌들에 대한 점수를 매깁니다.
                        blockCounter -= 1 // 현재 자리가 비어있으므로 해당 변수를 -1 시킵니다.
                        
                        score += getStoneSetScore(count: stoneCounter, blocks: blockCounter, isMax: isMax)
                        
                        stoneCounter = 0 // 연속된 돌을 다시 처음부터 세기위해 변수를 초기화 시킵니다.
                    }
                    blockCounter = 1 // 현재 지점이 비어있는 상태이므로 나머지 한쪽이 비어있으면 0, 비어있지 않으면 2가 되기 위해 해당 변수를 1로 설정합니다.
                } else { // 만약 현재 자리가 다른 돌에 의해 차지되어 있는 경우입니다.
                    if(stoneCounter > 0) { // stoneCounter가 1 이상이면 이전에 forStone 색상의 돌이 있었다는 의미로 해당 돌들에 대한 점수를 매깁니다.
                        score += getStoneSetScore(count: stoneCounter, blocks: blockCounter, isMax: isMax)
                        
                        // 연속된 돌을 다시 처음부터 세기위해 변수를 초기화 시킵니다.
                        stoneCounter = 0
                        blockCounter = 2
                    }
                }
            }
            
            if(stoneCounter >= 2) {  // 한 열에 대해 탐색 과정이 끝났다면, 끝나기 직전에 연속된 돌들이 있었는지 확인하고 점수를 매깁니다.
                score += getStoneSetScore(count: stoneCounter, blocks: blockCounter, isMax: isMax)
            }
            
            // 변수들을 초기화 합니다.
            stoneCounter = 0
            blockCounter = 2
        }
        
        // 상단 우측에서 하단 좌측으로 구성된 대각선을 탐색합니다.
        for j in 4 ..< boardSize * 2 - 5 { // 최대로 가질 수 있는 대각선의 연속된 돌이 5개 이상인 경우만 계산합니다.
            for i in 0 ..< boardSize {
                if(j - i < 0 || j - i >= boardSize) { // 보드판의 사이즈를 넘지 않을 경우 건너뜁니다.
                    continue
                }
                
                if(board[i][j - i] == forStone) { // 만약 연속된 돌이 있다면 카운터를 증가시킵니다.
                    stoneCounter += 1
                    
                } else if(board[i][j - i] == 0) { // 만약 현재 자리가 비었다면, 연속된 돌의 시작점 혹은 끝점으로 봅니다.
                    if(stoneCounter > 0) { // stoneCounter가 1 이상이면 이전에 forStone 색상의 돌이 있었다는 의미로 해당 돌들에 대한 점수를 매깁니다.
                        blockCounter -= 1 // 현재 자리가 비어있으므로 해당 변수를 -1 시킵니다.
                        
                        score += getStoneSetScore(count: stoneCounter, blocks: blockCounter, isMax: isMax)
                        
                        stoneCounter = 0 // 연속된 돌을 다시 처음부터 세기위해 변수를 초기화 시킵니다.
                    }
                    blockCounter = 1 // 현재 지점이 비어있는 상태이므로 나머지 한쪽이 비어있으면 0, 비어있지 않으면 2가 되기 위해 해당 변수를 1로 설정합니다.
                } else { // 만약 현재 자리가 다른 돌에 의해 차지되어 있는 경우입니다.
                    if(stoneCounter > 0) { // stoneCounter가 1 이상이면 이전에 forStone 색상의 돌이 있었다는 의미로 해당 돌들에 대한 점수를 매깁니다.
                        score += getStoneSetScore(count: stoneCounter, blocks: blockCounter, isMax: isMax)
                        
                        // 연속된 돌을 다시 처음부터 세기위해 변수를 초기화 시킵니다.
                        stoneCounter = 0
                        blockCounter = 2
                    }
                }
            }
            
            if(stoneCounter >= 2) {  // 한 열에 대해 탐색 과정이 끝났다면, 끝나기 직전에 연속된 돌들이 있었는지 확인하고 점수를 매깁니다.
                score += getStoneSetScore(count: stoneCounter, blocks: blockCounter, isMax: isMax)
            }
            
            // 변수들을 초기화 합니다.
            stoneCounter = 0
            blockCounter = 2
        }
    
        return score
    }
    
    // 연속된 돌에 대해 점수를 매깁니다.
    // count: 몇 개의 돌이 연속되어 있는지 나타냅니다.
    // blocks: 연속된 돌이 막혀있는지 확인하기 위한 변수입니다. 0: 연속된 돌의 양쪽이 비어있음, 1: 연속된 돌에서 위 혹은 아래만 비어있음, 2: 연속된 돌의 양쪽이 막혀있음.
    // isMax : 선행자의 돌의 우선시 되야하므로 선행자의 돌이 더 높은 점수를 가질 수 있도록 선행자인지 확인하기 위한 변수입니다.
    static func getStoneSetScore(count: Int, blocks: Int, isMax: Bool) -> Int {
        let winGuarantee = 1000000 // 해당 점수를 받으면 다음 판에 이긴다는 것을 보장합니다.
        
        // 만약 양쪽이 막혀있는 4개 이하의 연속된 돌이라면 필요없는 수로 판단합니다.
        if(blocks == 2 && count < 5) { return 0 }
        
        switch(count) {
        case 5: // 5개의 연속된 돌은 이긴 상태입니다.
            return winScore
        
        case 4: // 4개의 연속된 돌은 다음 판에 이길 수 있다는 의미입니다.
            if(isMax) { return winGuarantee }
            else {
                if(blocks == 0) { return winGuarantee/4 }
                return 200
            }
            
        case 3: // 3개의 연속된 돌에 대해 점수를 매깁니다.
            if(blocks == 0) {
                if(isMax) { return 50000 }
                return 200
            } else {
                if(isMax) { return 10 }
                return 5
            }
            
        case 2: // 2개의 연속된 돌에 대해 점수를 매깁니다.
            if(blocks == 0) {
                if(isMax) { return 7 }
                return 5
            }
            return 3
            
        case 1:
            return 1
            
        default: // 연속된 돌이 6개 이상일 경우 실행됩니다.
            return winScore * 2
        }
    }
}
