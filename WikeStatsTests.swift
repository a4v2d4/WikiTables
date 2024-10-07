import XCTest
@testable import WikiStats

// MARK: - Test Configuration
let testPlayerName = "Tom Brady"
let testPlayerCollege = "Michigan"
let testTimeout: TimeInterval = 10

class WikiStatsTests: XCTestCase {
    var viewModel: PlayerViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = PlayerViewModel()
    }
    
    func testSearchPlayers() {
        let expectation = XCTestExpectation(description: "Player search completes")
        
        viewModel.searchPlayers(searchText: testPlayerName)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertGreaterThan(self.viewModel.players.count, 0, "Search should return at least one player")
            XCTAssertTrue(self.viewModel.players.contains(where: { $0.name.contains(testPlayerName) }), "Search should return \(testPlayerName)")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: testTimeout)
    }
    
    func testScrapePage() {
        let expectation = XCTestExpectation(description: "Page scraping completes")
        
        viewModel.scrapePage(pageName: testPlayerName) { college, nflStats in
            XCTAssertTrue(college.contains(testPlayerCollege), "College stats should contain \(testPlayerCollege)")
            XCTAssertFalse(nflStats.isEmpty, "NFL stats should not be empty")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: testTimeout)
    }
}