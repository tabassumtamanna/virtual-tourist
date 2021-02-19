//
//  FlickrPhotosResponse.swift
//  VirtualTourist
//
//  Created by Tabassum Tamanna on 2/19/21.
//

import Foundation

struct FlickrPhotosResponse: Codable {
    
    let photos: FlickrPhotos
    let stat: String
}
