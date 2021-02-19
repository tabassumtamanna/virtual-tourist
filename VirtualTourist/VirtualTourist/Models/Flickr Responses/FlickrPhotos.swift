//
//  FlickrPhotos.swift
//  VirtualTourist
//
//  Created by Tabassum Tamanna on 2/19/21.
//

import Foundation

struct FlickrPhotos: Codable {
    
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [FlickrPhoto]
}
