//
//  FlickrErrorResponse.swift
//  VirtualTourist
//
//  Created by Tabassum Tamanna on 2/19/21.
//

import Foundation

struct FlickrErrorResponse: Codable, Error {
    let stat: String
    let code: Int
    let message: String

}

extension FlickrErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
