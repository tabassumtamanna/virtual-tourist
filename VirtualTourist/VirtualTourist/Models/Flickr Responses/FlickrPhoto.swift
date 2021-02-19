//
//  FlickrPhoto.swift
//  VirtualTourist
//
//  Created by Tabassum Tamanna on 2/19/21.
//

import Foundation

struct FlickrPhoto: Codable {
    
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
