//
//  InGameController.swift
//  gomoku
//
//  Created by 윤준영 on 2022/11/14.
//

import UIKit

let LINE_WIDTH = 1.0 // 선 굵기 (변경 자제)
let NUMBER_OF_BLOCK = 15 // 선 개수
let PADDING_SIZE = 15.0 // 여백 크기

class InGameController: UIViewController {
    var isAIFirst = false
    
    @IBOutlet weak var boardImage: UIImageView!
    @IBOutlet weak var stonesImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawBoard()
    }
    
    @IBAction func onExit(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // TabRecognizer 이벤트
    @IBAction func didTab(_ sender: UITapGestureRecognizer) {
        let SCREEN_WIDTH = UIScreen.main.bounds.width - PADDING_SIZE * 2.0
        let AVAILABLE_WIDTH: Double = SCREEN_WIDTH - Double(LINE_WIDTH * Double(NUMBER_OF_BLOCK)) - Double(LINE_WIDTH * 2.0)
        let BLOCK_SIZE = (AVAILABLE_WIDTH / Double(NUMBER_OF_BLOCK - 1)) + LINE_WIDTH
        let STONE_SIZE = BLOCK_SIZE * 0.9
        let HALF_STONE_SIZE = STONE_SIZE / 2.0
        
        let touchedPosX = sender.location(in: boardImage).x
        let touchedPosY = sender.location(in: boardImage).y
        var selectedLocX = -1
        var selectedLocY = -1
        
        // 사용자가 터치한 좌표를 기반삼아 어느 위치에 터치를 했는지 판별합니다.
        for counter in 0..<NUMBER_OF_BLOCK {
            let blockStartPosition = PADDING_SIZE + (BLOCK_SIZE * Double(counter)) - HALF_STONE_SIZE + LINE_WIDTH
            if touchedPosX >= blockStartPosition && touchedPosX <= blockStartPosition + STONE_SIZE {
                selectedLocX = counter
            }
            if touchedPosY >= blockStartPosition && touchedPosY <= blockStartPosition + STONE_SIZE {
                selectedLocY = counter
            }
        }
        
        if selectedLocX != -1 && selectedLocY != -1 {
            putStone(color: isAIFirst ? 1 : 0, x: selectedLocX, y: selectedLocY)
        }
    }
    
    /**
     오목판을 그립니다.
     */
    func drawBoard() {
        let SCREEN_WIDTH = UIScreen.main.bounds.width - PADDING_SIZE * 2.0
        let AVAILABLE_WIDTH: Double = SCREEN_WIDTH - Double(LINE_WIDTH * Double(NUMBER_OF_BLOCK)) - Double(LINE_WIDTH * 2.0)
        let BLOCK_SIZE = (AVAILABLE_WIDTH / Double(NUMBER_OF_BLOCK - 1)) + LINE_WIDTH
        
        UIGraphicsBeginImageContextWithOptions(boardImage.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setLineWidth(LINE_WIDTH)
                
        for i in 0..<NUMBER_OF_BLOCK {
            // 시작, 끝, 중간줄에 대해 색상을 다르게 줌
            if(i == NUMBER_OF_BLOCK / 2 || i == 0 || i == NUMBER_OF_BLOCK - 1) {
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
        let SCREEN_WIDTH = UIScreen.main.bounds.width - PADDING_SIZE * 2.0
        let AVAILABLE_WIDTH: Double = SCREEN_WIDTH - Double(LINE_WIDTH * Double(NUMBER_OF_BLOCK)) - Double(LINE_WIDTH * 2.0)
        let BLOCK_SIZE = (AVAILABLE_WIDTH / Double(NUMBER_OF_BLOCK - 1)) + LINE_WIDTH
        let STONE_SIZE = BLOCK_SIZE * 0.9
        let HALF_STONE_SIZE = STONE_SIZE / 2.0
        
        UIGraphicsBeginImageContextWithOptions(stonesImage.frame.size, false, 0.0)
        
        stonesImage.image?.draw(at: .zero) // 이전 context의 이미지를 그린다.
        
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
