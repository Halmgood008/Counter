import Foundation

struct Movie: Decodable {
    let title: String
    let rating: Double
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
