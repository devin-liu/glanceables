import Foundation

struct LlamaResult {
    let innerText: String?
    let conciseText: String?    
    
    init(innerText: String, conciseText: String?) {
        self.innerText = innerText
        self.conciseText = conciseText
    }
}
