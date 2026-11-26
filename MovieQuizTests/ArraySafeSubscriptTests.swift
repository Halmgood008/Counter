import XCTest
@testable import MovieQuiz

final class ArraySafeSubscriptTests: XCTestCase {
    
    func testGetValueInRange() {
        // Given
        let array = [1, 2, 3, 4, 5]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAssertEqual(value, 3, "Значение по индексу 2 должно быть 3")
    }
    
    func testGetValueOutOfRange() {
        // Given
        let array = [1, 2, 3, 4, 5]
        
        // When
        let value = array[safe: 5]
        
        // Then
        XCTAssertNil(value, "Значение за пределами массива должно быть nil")
    }
}
