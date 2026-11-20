import UIKit

protocol ImageLoaderProtocol {
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void)
}

final class ImageLoader: ImageLoaderProtocol {
    private let imageCache = NSCache<NSString, UIImage>()
    
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            self?.imageCache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
