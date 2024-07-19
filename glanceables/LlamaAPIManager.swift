import Foundation

// Class for managing interaction with the Llama API
class LlamaAPIManager: ObservableObject {    
    
    @Published var isSending: Bool = false
    @Published var response: String? = nil
    @Published var conciseText: String? = nil
    
    func analyzeHTML(htmlElements: [HTMLElement], completion: @escaping (Result<String, Error>) -> Void) {
        print("Started analyzing HTML elements")
        
        guard !htmlElements.isEmpty else {
            completion(.failure(NSError(domain: "LlamaAPIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No HTML elements to analyze."])))
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
        
        // Creating the prompt for analyzing HTML elements
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
        
        let body: [String: Any] = [
            "model": "llama3",
            "prompt": htmlAnalysisPrompt,
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
            defer { DispatchQueue.main.async { self.isSending = false } }  // Ensure isSending is reset after operation
            
            if let error = error {
                DispatchQueue.main.async { self.response = "Error: \(error.localizedDescription)" }  // Handle errors by updating the response
                return
            }
            
            // Ensure data was received
            guard let data = data else {
                DispatchQueue.main.async { self.response = "No data received" }  // Handle the absence of data
                return
            }
            
            let decoder = JSONDecoder()  // Initialize JSON decoder
            let lines = data.split(separator: 10)  // Split the data into lines
            var responses = [String]()  // Array to hold the decoded responses
            
            // Iterate over each line of data
            for line in lines {
                if let jsonLine = try? decoder.decode(Response.self, from: Data(line)) {
                    responses.append(jsonLine.response)  // Decode each line and append the response
                }
            }
            
            DispatchQueue.main.async {
                self.response = responses.joined(separator: "")  // Combine all responses into one string
                
                // Convert response to JSON and extract the value for "concise_text"
                if let responseString = self.response,
                   let data = responseString.data(using: .utf8) {
                    do {
                        // Convert the JSON string to a dictionary
                        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            // Extract the value for "concise_text"
                            if let conciseText = jsonObject["concise_text"] as? String {
                                print(conciseText)
                                self.conciseText = conciseText
                            } else {
                                print("Key 'concise_text' not found or value is not a string", jsonObject)
                            }
                        } else {
                            print("Failed to convert JSON data to dictionary")
                        }
                    } catch {
                        print("Error during JSON deserialization: \(error)")
                    }
                } else {
                    print("Response is nil or invalid")
                }
            }
        }.resume()  // Resume the task if it was suspended
    }
}
