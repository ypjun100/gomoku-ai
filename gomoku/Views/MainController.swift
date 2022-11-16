import UIKit

class MainController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let inGameView = segue.destination as? InGameController else {
            return
        }
        inGameView.isAIFirst = segmentControl.selectedSegmentIndex == 0 ? false : true // AI의 선공/후공 여부를 InGameController로 보냄
    }
}

