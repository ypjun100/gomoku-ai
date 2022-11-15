//
//  InGameController.swift
//  gomoku
//
//  Created by 윤준영 on 2022/11/14.
//

import UIKit

let LINE_WIDTH = 1.0 // 선 굵기 (변경 자제)
let BOARD_SIZE = 15 // 보드 크기
let PADDING_SIZE = 15.0 // 여백 크기

class InGameController: UIViewController {
    var isAIFirst = false
    var gomokuManager: GomokuManager!
    
    @IBOutlet weak var boardImage: UIImageView!
    @IBOutlet weak var stonesImage: UIImageView!
    @IBOutlet weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gomokuManager = GomokuManager(boardSize: BOARD_SIZE, isAIFirst: isAIFirst)
        drawBoard()
        
        if(isAIFirst) {
            putStone(color: 0, x: BOARD_SIZE / 2, y: BOARD_SIZE / 2)
        }
    }
    
    @IBAction func onExit(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // TabRecognizer 이벤트
    @IBAction func didTab(_ sender: UITapGestureRecognizer) {
        let SCREEN_WIDTH = UIScreen.main.bounds.width - PADDING_SIZE * 2.0
        let AVAILABLE_WIDTH: Double = SCREEN_WIDTH - Double(LINE_WIDTH * Double(BOARD_SIZE)) - Double(LINE_WIDTH * 2.0)
        let BLOCK_SIZE = (AVAILABLE_WIDTH / Double(BOARD_SIZE - 1)) + LINE_WIDTH
        let STONE_SIZE = BLOCK_SIZE * 0.9
        let HALF_STONE_SIZE = STONE_SIZE / 2.0
        
        let touchedPosX = sender.location(in: boardImage).x
        let touchedPosY = sender.location(in: boardImage).y
        var selectedLocX = -1
        var selectedLocY = -1
        
        // 사용자가 터치한 좌표를 기반삼아 어느 위치에 터치를 했는지 판별합니다.
        for counter in 0..<BOARD_SIZE {
            let blockStartPosition = PADDING_SIZE + (BLOCK_SIZE * Double(counter)) - HALF_STONE_SIZE + LINE_WIDTH
            if touchedPosX >= blockStartPosition && touchedPosX <= blockStartPosition + STONE_SIZE {
                selectedLocX = counter
            }
            if touchedPosY >= blockStartPosition && touchedPosY <= blockStartPosition + STONE_SIZE {
                selectedLocY = counter
            }
        }
        
        if selectedLocX != -1 && selectedLocY != -1 {
            putStone(color: isAIFirst ? 1 : 0, x: selectedLocX, y: selectedLocY) // 플레이어 돌을 놓습니다.
            
            OperationQueue.main.addOperation({
                let aiMove = self.gomokuManager?.calculateNextMove(playerMoveI: selectedLocY, playerMoveJ: selectedLocX, playerStone: self.isAIFirst ? 2 : 1)
                self.putStone(color: self.isAIFirst ? 0 : 1, x: aiMove![1], y: aiMove![0])
            })
        }
    }
    
    /**
     오목판을 그립니다.
     */
    func drawBoard() {
        let SCREEN_WIDTH = UIScreen.main.bounds.width - PADDING_SIZE * 2.0
        let AVAILABLE_WIDTH: Double = SCREEN_WIDTH - Double(LINE_WIDTH * Double(BOARD_SIZE)) - Double(LINE_WIDTH * 2.0)
        let BLOCK_SIZE = (AVAILABLE_WIDTH / Double(BOARD_SIZE - 1)) + LINE_WIDTH
        
        UIGraphicsBeginImageContextWithOptions(boardImage.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setLineWidth(LINE_WIDTH)
                
        for i in 0..<BOARD_SIZE {
            // 시작, 끝, 중간줄에 대해 색상을 다르게 줌
            if(i == BOARD_SIZE / 2 || i == 0 || i == BOARD_SIZE - 1) {
                context.setStrokeColor(CGColor(gray: 0.6, alpha: 1.0))
            } else {
                context.setStrokeColor(CGColor(gray: 0.3, alpha: 1.0))
            }
            // 가로줄
            context.move(to: CGPoint(x: PADDING_SIZE, y: Double(i) * BLOCK_SIZE + LINE_WIDTH + PADDING_SIZE))
            context.addLine(to: CGPoint(x: SCREEN_WIDTH + PADDING_SIZE - LINE_WIDTH, y: Double(i) * BLOCK_SIZE + LINE_WIDTH + PADDING_SIZE))
            context.strokePath()
            
            //세로줄
            context.move(to: CGPoint(x: Double(i) * BLOCK_SIZE + LINE_WIDTH + PADDING_SIZE, y: PADDING_SIZE))
            context.addLine(to: CGPoint(x: Double(i) * BLOCK_SIZE + LINE_WIDTH + PADDING_SIZE, y: SCREEN_WIDTH + PADDING_SIZE - LINE_WIDTH))
            context.strokePath()
        }
        
        boardImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    /**
     돌을 놓습니다.
     - Parameters:
        - color: 돌의 색을 지정합니다. (0-황, 1-백)
        - x: 돌의 x축 위치를 지정합니다.
        - y: 돌의 y축 위치를 지정합니다.
     */
    func putStone(color: Int, x: Int, y: Int) {
        if(gomokuManager.putStone(i: y, j: x, stone: color == 0 ? 1 : 2)) { // 돌을 놓을 자리에 이미 다른 돌이 있는지 확인합니다.
            logTextView.text = logTextView.text + "\n> \(color == (isAIFirst ? 0 : 1) ? "AI" : "플레이어")가 (\(x), \(y))에 착수하였습니다."
        } else {
            logTextView.text = logTextView.text + "\n! 이미 착수된 자리입니다."
            return
        }
        
        let SCREEN_WIDTH = UIScreen.main.bounds.width - PADDING_SIZE * 2.0
        let AVAILABLE_WIDTH: Double = SCREEN_WIDTH - Double(LINE_WIDTH * Double(BOARD_SIZE)) - Double(LINE_WIDTH * 2.0)
        let BLOCK_SIZE = (AVAILABLE_WIDTH / Double(BOARD_SIZE - 1)) + LINE_WIDTH
        let STONE_SIZE = BLOCK_SIZE * 0.9
        let HALF_STONE_SIZE = STONE_SIZE / 2.0
        
        UIGraphicsBeginImageContextWithOptions(stonesImage.frame.size, false, 0.0)
        
        stonesImage.image?.draw(at: .zero) // 이전 context의 이미지를 그립니다.
        
        let context = UIGraphicsGetCurrentContext()!
        
        if(color == 0) {
            context.setFillColor(CGColor(red: 0.937, green: 0.752, blue: 0.066, alpha: 1.0))
        } else {
            context.setFillColor(CGColor(red: 0.929, green: 0.929, blue: 0.929, alpha: 1.0))
        }
        
        context.addEllipse(in: CGRect(x: PADDING_SIZE + (BLOCK_SIZE * Double(x)) - HALF_STONE_SIZE + LINE_WIDTH, y: PADDING_SIZE + (BLOCK_SIZE * Double(y)) - HALF_STONE_SIZE + LINE_WIDTH,
                                      width: STONE_SIZE, height: STONE_SIZE))
        context.drawPath(using: .fill)
        
        stonesImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
