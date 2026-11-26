import XCTest
@testable import MovieQuiz

final class MoviesLoaderTests: XCTestCase {
    
    class MockURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
        override func resume() {}
    }
    
    class MockURLSession: URLSessionProtocol {
        var testData: Data?
        
        func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            completionHandler(testData, nil, nil)
            return MockURLSessionDataTask()
        }
    }
    
    func testSuccessLoading() {
        // Given
        let json = """
        {
            "items": [
                {
                    "title": "The Shawshank Redemption",
                    "imDbRating": 9.3,
                    "image": "https://example.com/image.jpg"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let session = MockURLSession()
        session.testData = json
        let loader = MoviesLoader(session: session)
        let expectation = self.expectation(description: "Загрузка фильмов")
        var result: Result<[Movie], Error>?
        
        // When
        loader.loadMovies { res in
            result = res
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0)
        
        // Then
        switch result {
        case .success(let movies):
            XCTAssertEqual(movies.count, 1)
            XCTAssertEqual(movies.first?.title, "The Shawshank Redemption")
            XCTAssertEqual(movies.first?.rating, 9.3)
        default:
            XCTFail("Ожидался успех, но пришла ошибка")
        }
    }
    
    func testErrorLoading() {
        // Given
        let session = MockURLSession()
        session.testData = "invalid json".data(using: .utf8)!
        let loader = MoviesLoader(session: session)
        let expectation = self.expectation(description: "Загрузка с ошибкой")
        var result: Result<[Movie], Error>?
        
        // When
        loader.loadMovies { res in
            result = res
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0)
        
        // Then
        switch result {
        case .failure(let error):
            XCTAssertNotNil(error)
        default:
            XCTFail("Ожидалась ошибка, но пришел успех")
        }
    }
}
