//import Foundation
//import Combine
//
//class URLAutocompleteViewModel: ObservableObject {
//    @Published var suggestions: [String] = []
//
//    func fetchAutocompleteSuggestions(query: String) {
//        guard !query.isEmpty else {
//            suggestions = []
//            return
//        }
//        let urlString = "https://suggestqueries.google.com/complete/search?client=safari&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else {
//                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            
//            do {
//                // Google's API returns an array of results, where the first element is the query
//                // and the second element is an array of suggestions.
//                if let result = try JSONSerialization.jsonObject(with: data) as? [Any],
//                   result.count >= 2,
//                   let suggestions = result[1] as? [String] {
//                    DispatchQueue.main.async {
//                        self.suggestions = suggestions
//                    }
//                }
//            } catch {
//                print("Failed to decode suggestions: \(error.localizedDescription)")
//            }
//        }.resume()
//    }
//}
