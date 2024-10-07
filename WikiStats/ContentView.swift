import SwiftUI
import Kanna

struct Player: Codable, Identifiable {
    var id = UUID()
    let name: String
    var college: String
    var nflStats: String
    var tables: [String: Table] = [:]
}

struct Table: Codable {
    var headers: [String]
    var rows: [[String]]
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
    
    func scrapePage(pageName: String, completion: @escaping (String, String, [String: Table]) -> Void) {
        let urlString = "https://en.wikipedia.org/wiki/\(pageName.replacingOccurrences(of: " ", with: "_"))"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            if let html = String(data: data, encoding: .utf8) {
                do {
                    let doc = try HTML(html: html, encoding: .utf8)
                    
                    let college = doc.xpath("//th[contains(text(), 'College')]/following-sibling::td").first?.text ?? ""
                    let nflStats = doc.xpath("//span[@id='NFL_career_statistics']/ancestor::h2/following-sibling::p").first?.text ?? ""
                    
                    var tables: [String: Table] = [:]
                    
                    if let collegeStatsTable = doc.xpath("//span[@id='College_statistics']/ancestor::h2/following-sibling::table[@class='wikitable']").first {
                        var headers: [String] = []
                        var rows: [[String]] = []
                        
                        collegeStatsTable.xpath(".//tr").forEach { row in
                            let rowData = row.xpath(".//th|.//td").map { $0.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
                            if headers.isEmpty {
                                headers = rowData
                            } else {
                                rows.append(rowData)
                            }
                        }
                        
                        tables["College statistics"] = Table(headers: headers, rows: rows)
                    }
                    
                    completion(college, nflStats, tables)
                } catch {
                    print("Error parsing HTML: \(error)")
                    completion("", "", [:])
                }
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
            .searchable(text: $searchText)
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
                            CollegeStatsTable(table: tableData)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(player.name)
    }
}

struct CollegeStatsTable: View {
    let table: Table
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 0) {
                Text("Season")
                    .frame(width: 60, alignment: .center)
                    .padding(5)
                    .border(Color.gray, width: 0.5)
                Text("Team")
                    .frame(width: 100, alignment: .center)
                    .padding(5)
                    .border(Color.gray, width: 0.5)
                VStack(spacing: 0) {
                    Text("Passing")
                        .frame(maxWidth: .infinity)
                        .padding(5)
                        .border(Color.gray, width: 0.5)
                    HStack(spacing: 0) {
                        ForEach(["Cmp", "Att", "Pct", "Yds", "Y/A", "TD", "Int", "Rtg"], id: \.self) { header in
                            Text(header)
                                .frame(width: 40, alignment: .center)
                                .padding(5)
                                .border(Color.gray, width: 0.5)
                        }
                    }
                }
                VStack(spacing: 0) {
                    Text("Rushing")
                        .frame(maxWidth: .infinity)
                        .padding(5)
                        .border(Color.gray, width: 0.5)
                    HStack(spacing: 0) {
                        ForEach(["Att", "Yds", "Avg", "TD"], id: \.self) { header in
                            Text(header)
                                .frame(width: 40, alignment: .center)
                                .padding(5)
                                .border(Color.gray, width: 0.5)
                        }
                    }
                }
            }
            
            // Rows
            ForEach(table.rows.indices, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    ForEach(table.rows[rowIndex].indices, id: \.self) { colIndex in
                        Text(table.rows[rowIndex][colIndex])
                            .frame(width: colIndex < 2 ? (colIndex == 0 ? 60 : 100) : 40, alignment: .center)
                            .padding(5)
                            .border(Color.gray, width: 0.5)
                            .background(rowIndex % 2 == 1 ? Color.gray.opacity(0.1) : Color.clear)
                    }
                }
            }
        }
        .border(Color.gray, width: 1)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
