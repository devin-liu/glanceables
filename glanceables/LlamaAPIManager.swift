import Foundation

// Class for managing interaction with the Llama API
class LlamaAPIManager: ObservableObject {
    
    static let shared = LlamaAPIManager()
    
    @Published var isSending: Bool = false
    @Published var response: String? = nil

    func interpretChanges(htmlElements: [HTMLElement], completion: @escaping (Result<String, Error>) -> Void) {
        print("Started interpreting changes")
        
        guard !htmlElements.isEmpty else {
            completion(.failure(NSError(domain: "LlamaAPIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No HTML elements to interpret."])))
            return
        }
        
        guard !isSending else {
            completion(.failure(NSError(domain: "LlamaAPIManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Request is already in progress."])))
            return
        }
        
        isSending = true
        
        let urlString = "http://127.0.0.1:11434/api/generate"
        guard let url = URL(string: urlString) else {
            isSending = false
            completion(.failure(NSError(domain: "LlamaAPIManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "llama3",
            "prompt": htmlElements.map { $0.innerHTML }.joined(separator: ", "),
            "options": ["num_ctx": 4096]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            isSending = false
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { DispatchQueue.main.async { self.isSending = false } }
            
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "LlamaAPIManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "No data received from API."]))) }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseString = try decoder.decode(String.self, from: data)
                
                DispatchQueue.main.async {
                    self.response = responseString
                    completion(.success(responseString))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}
