import UIKit

let LINE_WIDTH = 1.0    // 선 굵기 (변경 자제)
let BOARD_SIZE = 15     // 보드 크기
let PADDING_SIZE = 15.0 // 여백 크기

class InGameController: UIViewController {
    private var SCREEN_WIDTH = 0.0     // 화면 가로 크기
    private var AVAILABLE_WIDTH = 0.0  // 그릴 수 있는 가능한 크기
    private var BLOCK_SIZE = 0.0       // 한 블록당 크기
    private var STONE_SIZE = 0.0       // 돌 크기
    private var HALF_STONE_SIZE = 0.0  // 돌 크기의 반의 크기
    
    var isAIFirst = false // AI가 선공인지 후공인지 결정합니다.
    private var gomokuManager: GomokuManager! // 게임을 총괄적으로 관리합니다.
    
    @IBOutlet private weak var boardImage: UIImageView! // 보드판 이미지
    @IBOutlet private weak var stonesImage: UIImageView! // 돌이 놓일 이미지
    @IBOutlet private weak var logTextView: UITextView! // 로그 텍스트
    @IBOutlet private weak var tapGestureRecognizer: UITapGestureRecognizer! // 사용자 터치 이벤트를 받을 recognizer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initalize() // 초기화를 진행합니다.
    }
    
    // 게임을 실행하기 위한 초기화를 진행합니다.
    func initalize() {
        // 변수들을 초기화합니다.
        SCREEN_WIDTH = UIScreen.main.bounds.width - PADDING_SIZE * 2.0
        AVAILABLE_WIDTH = SCREEN_WIDTH - Double(LINE_WIDTH * Double(BOARD_SIZE)) - Double(LINE_WIDTH * 2.0)
        BLOCK_SIZE = (AVAILABLE_WIDTH / Double(BOARD_SIZE - 1)) + LINE_WIDTH
        STONE_SIZE = BLOCK_SIZE * 0.9
        HALF_STONE_SIZE = STONE_SIZE * 0.5
        
        gomokuManager = GomokuManager(inGameController: self, boardSize: BOARD_SIZE, isAIFirst: isAIFirst) // Gomoku 매니저를 생성합니다.
        
        drawBoard() // 보드판을 그립니다.
    }
    
    // 종료 버튼 이벤트
    @IBAction func onExit(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // TabRecognizer 이벤트
    @IBAction func didTab(_ sender: UITapGestureRecognizer) {
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
            if(gomokuManager.putStone(i: selectedLocY, j: selectedLocX, stone: isAIFirst ? 2 : 1)) {
                setUserInteractive(isEnabled: false) // AI의 계산을 위해 사용자의 터치 입력을 제한합니다.
                gomokuManager.run() // AI의 다음수를 계산합니다.
            } else {
                logTextView.appendLine(text: "! 이미 착수된 지점입니다.")
            }
        }
    }
    
    // UIGraphics를 이용해 오목판을 그립니다.
    func drawBoard() {
        UIGraphicsBeginImageContextWithOptions(boardImage.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setLineWidth(LINE_WIDTH)
                
        for i in 0..<BOARD_SIZE {
            // 시작, 끝, 중간줄에 대해 색상을 다르게 줍니다.
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
    
    // 특정 위치에 특정 색의 돌을 놓습니다.
    // 현재 클래스에서 실행되는 것이 아닌 GomokuManager 클래스에 의해 실행됩니다.
    // color: 돌 색상입니다.(0: 황, 1: 백)
    // i: 돌의 y축상의 위치입니다.
    // j: 돌의 x축상의 위치입니다.
    func putStone(color: Int, i: Int, j: Int) {
        UIGraphicsBeginImageContextWithOptions(stonesImage.frame.size, false, 0.0) // UIImage가 흐려지는것을 방지하기 위해 옵션을 지정합니다.
        
        stonesImage.image?.draw(at: .zero) // 이전 context의 이미지를 그립니다.
        
        let context = UIGraphicsGetCurrentContext()!
        
        if(color == 0) {
            context.setFillColor(CGColor(red: 0.937, green: 0.752, blue: 0.066, alpha: 1.0)) // 황색
        } else {
            context.setFillColor(CGColor(red: 0.929, green: 0.929, blue: 0.929, alpha: 1.0)) // 백색
        }
        
        context.addEllipse(in: CGRect(x: PADDING_SIZE + (BLOCK_SIZE * Double(j)) - HALF_STONE_SIZE + LINE_WIDTH, y: PADDING_SIZE + (BLOCK_SIZE * Double(i)) - HALF_STONE_SIZE + LINE_WIDTH,
                                      width: STONE_SIZE, height: STONE_SIZE)) // 돌 추가
        context.drawPath(using: .fill)
        
        stonesImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        logTextView.appendLine(text: "> \(color == (isAIFirst ? 0 : 1) ? "AI" : "플리에어")가 (\(j), \(i))에 착수하였습니다.")
        setUserInteractive(isEnabled: true) // 사용자 터치 이벤트 제한을 해제합니다.
    }
    
    // AI 혹은 사용자의 승리로 인해 게임을 종료합니다.
    func terminateGame(message: String) {
        setUserInteractive(isEnabled: false) // 사용자 터치 이벤트를 제한합니다.
        logTextView.appendLine(text: message)
    }
    
    // 사용자가 보드판을 터치하는 것을 허용할지를 결정합니다.
    func setUserInteractive(isEnabled: Bool) {
        tapGestureRecognizer.isEnabled = isEnabled
    }
}
