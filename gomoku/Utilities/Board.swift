import Foundation

// 게임 보드 클래스
class Board {
    private var board: [[Int]] // 실제 게임 보드 데이터
    
    // 기존의 배열을 기반으로 새로운 게임 보드를 생성합니다.
    init(board: [[Int]]) {
        self.board = board
    }
    
    // 보드 사이즈를 참고하여 빈 게임 보드를 생성합니다.
    init(boardSize: Int) {
        self.board = Array(repeating: Array(repeating: 0, count: boardSize), count: boardSize)
    }
    
    // 보드 사이즈를 반환합니다.
    func getSize() -> Int { return self.board.count }
    
    // 현재 게임 보드의 데이터를 반환합니다.
    func getBoardArray() -> [[Int]] { return self.board }
    
    // 현재 게임 보드의 상태를 표시합니다.
    func show() {
        // x축 라벨
        print("   ", terminator: "")
        for x in 0 ..< board.count {
            print(String(format: "%02d", x), terminator: " ")
        }
        print("")
        // y축 라벨과 보드판 데이터
        for y in 0 ..< board.count {
            print(String(format: "%02d", y), terminator: " ")
            for xdata in board[y] {
                print(" " + String(xdata), terminator: " ")
            }
            print("")
        }
    }
    
    // 특정 색상의 돌을 특정 위치에 놓습니다.
    // 만약 특정 위치에 이미 다른 돌이 있다면 'false'를 반환합니다.
    // stone: 1(흑), 2(백)
    func putStone(i: Int, j: Int, stone: Int) -> Bool {
        if(board[i][j] == 0) {
            board[i][j] = stone
            return true
        }
        return false
    }
    
    // 특정 위치의 돌을 삭제합니다.
    func removeStone(i: Int, j: Int) {
        board[i][j] = 0
    }
    
    // 게임 보드에서 새로운 돌을 놓을 수 있는 위치를 알아냅니다.
    // 0 0 0 0
    // 0 1 1 0
    // 0 0 0 0
    // 위 상태에서 돌을 놓을 수 있는 위치는 '1 1'의 주변인 총 10개입니다.
    func generateMoves() -> [[Int]] {
        var possibleMoves = Set<[Int]>()
        
        for i in 0 ..< getSize() {
            for j in 0 ..< getSize() {
                if(board[i][j] != 0) {
                    // 8방향에 대한 이중반복문
                    for q in -1 ... 1 {
                        for p in -1 ... 1 {
                            if(q != 0 || p != 0) {
                                if(i + q < 0 || i + q >= getSize() || j + p < 0 || j + p >= getSize()) { continue }
                                if(board[i + q][j + p] == 0) { // 해당 자리가 비어있을 때만 possibleMoves에 저장합니다.
                                    possibleMoves.insert([i + q, j + p])
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return Array(possibleMoves)
    }
}
