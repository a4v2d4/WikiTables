import SwiftUI
import Kanna

struct Player: Codable, Identifiable {
    var id = UUID()
    let name: String
    var college: String
    var nflStats: String
    var tables: [String: [[String]]] = [:]
}

class PlayerViewModel: ObservableObject {
    @Published var players: [Player] = []
    
    func searchPlayers(searchText: String) {
        let urlString = "https://en.wikipedia.org/w/api.php?action=opensearch&search=\(searchText)&limit=10&namespace=0&format=json"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            if let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any],
               let searchResults = jsonArray[1] as? [String] {
                DispatchQueue.main.async {
                    self.players = searchResults.map { Player(name: $0, college: "", nflStats: "") }
                }
                
                self.players.forEach { player in
                    self.scrapePage(pageName: player.name) { college, nflStats, tables in
                        DispatchQueue.main.async {
                            if let index = self.players.firstIndex(where: { $0.name == player.name }) {
                                self.players[index].college = college
                                self.players[index].nflStats = nflStats
                                self.players[index].tables = tables
                            }
                        }
                    }
                }
            }
        }.resume()
    }
    
    func scrapePage(pageName: String, completion: @escaping (String, String, [String: [[String]]]) -> Void) {
        let urlString = "https://en.wikipedia.org/wiki/\(pageName)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            if let html = String(data: data, encoding: .utf8),
               let doc = try? HTML(html: html, encoding: .utf8) {
                
                let college = doc.xpath("//th[contains(text(), 'College')]/following-sibling::td").first?.text ?? ""
                let nflStats = doc.xpath("//span[contains(text(), 'NFL stats')]/ancestor::p").first?.text ?? ""
                
                var tables: [String: [[String]]] = [:]
                
                doc.xpath("//table[@class='wikitable']").enumerated().forEach { (index, table) in
                    var tableData: [[String]] = []
                    table.xpath(".//tr").forEach { row in
                        let rowData = row.xpath(".//th|.//td").map { $0.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
                        tableData.append(rowData)
                    }
                    tables["Table \(index + 1)"] = tableData
                }
                
                completion(college, nflStats, tables)
            }
        }.resume()
    }
}

struct ContentView: View {
    @StateObject private var viewModel = PlayerViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List(viewModel.players) { player in
                NavigationLink(destination: PlayerDetailView(player: player)) {
                    VStack(alignment: .leading) {
                        Text(player.name)
                            .font(.headline)
                        Text("College: \(player.college)")
                        Text("NFL Stats: \(player.nflStats)")
                    }
                }
            }
            .searchable(text: $searchText) {
                ForEach(viewModel.players) { player in
                    Text(player.name).searchCompletion(player.name)
                }
            }
            .navigationTitle("WikiStats")
            .onChange(of: searchText) { newValue in
                viewModel.searchPlayers(searchText: newValue)
            }
        }
    }
}

struct PlayerDetailView: View {
    let player: Player
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(player.name)
                    .font(.largeTitle)
                Text("College: \(player.college)")
                    .font(.headline)
                Text("NFL Stats: \(player.nflStats)")
                    .font(.headline)
                
                ForEach(Array(player.tables.keys.sorted()), id: \.self) { tableName in
                    VStack(alignment: .leading) {
                        Text(tableName)
                            .font(.title2)
                        
                        if let tableData = player.tables[tableName] {
                            Table(tableData)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(player.name)
    }
}

struct Table: View {
    let data: [[String]]
    
    init(_ data: [[String]]) {
        self.data = data
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(data.indices, id: \.self) { rowIndex in
                HStack {
                    ForEach(data[rowIndex].indices, id: \.self) { colIndex in
                        Text(data[rowIndex][colIndex])
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(5)
                            .background(rowIndex == 0 ? Color.gray.opacity(0.3) : Color.clear)
                    }
                }
                .background(rowIndex % 2 == 1 ? Color.gray.opacity(0.1) : Color.clear)
            }
        }
        .border(Color.gray, width: 1)
    }
}
