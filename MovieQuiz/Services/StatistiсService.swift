import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    
    func saveResult(correct count: Int, total amount: Int)
}

final class StatisticService: StatisticServiceProtocol {
    
    private enum Keys: String {
        case correct, total, bestGameCorrect, bestGameTotal, bestGameDate, gamesCount
    }
    
    private let userDefaults = UserDefaults.standard
    
    var gamesCount: Int {
        get { userDefaults.integer(forKey: Keys.gamesCount.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue) }
        }
        
    var bestGame: GameResult {
        get {
            let correct = userDefaults.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = userDefaults.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = userDefaults.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            userDefaults.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            userDefaults.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            userDefaults.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
                
    var totalAccuracy: Double {
        let totalCorrect = userDefaults.integer(forKey: Keys.correct.rawValue)
        let totalQuestions = userDefaults.integer(forKey: Keys.total.rawValue)
        guard totalQuestions > 0 else { return 0 }
        return (Double(totalCorrect) / Double(totalQuestions)) * 100
    }
                
    func saveResult(correct count: Int, total amount: Int) {
        let currentCorrect = userDefaults.integer(forKey: Keys.correct.rawValue)
        let currentTotal = userDefaults.integer(forKey: Keys.total.rawValue)
        userDefaults.set(currentCorrect + count, forKey: Keys.correct.rawValue)
        userDefaults.set(currentTotal + amount, forKey: Keys.total.rawValue)
        
        gamesCount += 1
        
        let newResult = GameResult(correct: count, total: amount, date: Date())
        if newResult.isBetterThan(bestGame) {
            bestGame = newResult
        }
    }
}
