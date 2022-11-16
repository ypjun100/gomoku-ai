import UIKit

extension UITextView {
    // 텍스트뷰에 문자열 line을 추가시킵니다.
    func appendLine(text: String) {
        self.text = self.text + "\n\(text)"
        
        // 스크롤을 아래로 이동시킵니다.
        let bottom = NSMakeRange(self.text.count - 1, 1)
        self.scrollRangeToVisible(bottom)
    }
}
