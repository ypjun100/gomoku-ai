//
//  ViewController.swift
//  gomoku
//
//  Created by 윤준영 on 2022/11/14.
//

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
        inGameView.isAIFirst = segmentControl.selectedSegmentIndex == 0 ? false : true
    }
}

