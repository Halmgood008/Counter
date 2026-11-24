import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        sleep(4)
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    func testYesButtonChangesQuestion() throws {
        let yesButton = app.buttons["Да"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 5))
        
        let counterLabel = app.staticTexts["1/10"]
        XCTAssertTrue(counterLabel.exists)
        
        yesButton.tap()
        sleep(2)
        
        XCTAssertTrue(app.staticTexts["2/10"].exists)
    }
    
    func testNoButtonChangesQuestion() throws {
        let noButton = app.buttons["Нет"]
        XCTAssertTrue(noButton.waitForExistence(timeout: 5))
        
        let counterLabel = app.staticTexts["1/10"]
        XCTAssertTrue(counterLabel.exists)
        
        noButton.tap()
        sleep(2)
        
        XCTAssertTrue(app.staticTexts["2/10"].exists)
    }
    
    func testAlertAppearsAndRestartsQuiz() throws {
        let yesButton = app.buttons["Да"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 5))
        

        for _ in 1...10 {
            yesButton.tap()
            sleep(2)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        
        let alertButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(alertButton.exists)
        
        alertButton.tap()
        
        sleep(1)
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(app.staticTexts["1/10"].exists)
    }
}
