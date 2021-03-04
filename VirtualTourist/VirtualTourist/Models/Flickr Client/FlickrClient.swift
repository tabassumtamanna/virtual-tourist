//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Tabassum Tamanna on 2/18/21.
//

import Foundation

// MARK: - Flickr Client
class FlickrClient{
    
    static let apiKey = "16980c7510814b7f926bc6f57259ee3a"
    static let perPage  = 15
    
    enum Endpoints{
        
        case getPhotos(Double, Double, Int)
        case downloadImages(Int, String,  String, String)
        
        var stringValue: String{
            switch self {
            case .getPhotos(let lat, let long, let page):
                return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(lat)&lon=\(long)&page=\(page)&per_page=\(perPage)&format=json&nojsoncallback=1"
                
            case .downloadImages(let farmId, let serverId, let id, let secret):
                return "https://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
            }
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    // MARK: - Task For GET Request
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
       
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do{
                    let errorResponse = try decoder.decode(FlickrErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    // MARK: -  Get Photos
    class func getPhotos(lat: Double, long: Double, totalPages: Int, completion: @escaping (FlickrPhotos?, Error?) -> Void){
        
        let page = totalPages > 1 ? Int.random(in: 1..<totalPages) : 1
        print("page: \(page)")
        taskForGETRequest(url: Endpoints.getPhotos(lat, long, page).url, responseType: FlickrPhotosResponse.self) { (response, error) in
            
            if let response = response {
                completion(response.photos, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    // MARK: -  Download Images
    class func downloadImages(farmId: Int,  serverId: String, id: String, secret: String, completion: @escaping (Data?, Error?) -> Void){
        
        let task = URLSession.shared.dataTask(with: Endpoints.downloadImages(farmId, serverId, id, secret).url) { data, response, error in
        
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
}


