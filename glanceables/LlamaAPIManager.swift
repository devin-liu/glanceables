import Foundation

// Class for managing interaction with the Llama API
class LlamaAPIManager: ObservableObject {
    
    @Published var isSending: Bool = false
    @Published var response: String? = nil
    @Published var conciseText: String? = nil
    
    // Modular function to perform the API request
    private func performRequest(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
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
            "prompt": prompt,
            "options": ["num_ctx": 4096],
            "format": "json",
            "stream": false,
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
                DispatchQueue.main.async { self.response = "Error: \(error.localizedDescription)" }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { self.response = "No data received" }
                return
            }
            
            let decoder = JSONDecoder()
            let lines = data.split(separator: 10)
            var responses = [String]()
            
            for line in lines {
                if let jsonLine = try? decoder.decode(Response.self, from: Data(line)) {
                    responses.append(jsonLine.response)
                }
            }
            
            DispatchQueue.main.async {
                self.response = responses.joined(separator: "")
                if let responseString = self.response,
                   let data = responseString.data(using: .utf8),
                   let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let conciseText = jsonObject["concise_text"] as? String {
                    self.conciseText = conciseText
                    completion(.success(conciseText))
                } else {
                    completion(.failure(NSError(domain: "LlamaAPIManager", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON data or 'concise_text' key missing."])))
                }
            }
        }.resume()
    }
    
    func analyzeInnerText(innerText: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !innerText.isEmpty else {
            completion(.failure(NSError(domain: "LlamaAPIManager", code: 6, userInfo: [NSLocalizedDescriptionKey: "Empty innerText."])))
            return
        }
        
        let innerTextPrompt = """
        InnerText Input:
        \(innerText)
        
        Output JSON:
        {
            "concise_text": Analyze inner text to produce readable text for humans.
        }
        """
        
        performRequest(prompt: innerTextPrompt, completion: completion)
    }
    
    func analyzeHTML(htmlElements: [HTMLElement], completion: @escaping (Result<String, Error>) -> Void) {
        print("Started analyzing HTML elements")
        guard !htmlElements.isEmpty else {
            completion(.failure(NSError(domain: "LlamaAPIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No HTML elements to analyze."])))
            return
        }
        
        let htmlAnalysisPrompt = """
        HTML Input:
        \(
            htmlElements.map { "<div>\($0.outerHTML)</div>" }.joined(separator: "\n")
        )
        
        Output JSON:
        {
            "concise_text": Analyze HTML to produce readable text for humans.
        }
        """
        
        performRequest(prompt: htmlAnalysisPrompt, completion: completion)
    }
}
