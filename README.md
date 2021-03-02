# Virtual Tourist

Virtual tourist is a project for iOS Developer Nanodegree program at Udacity

[![Swift Version](https://img.shields.io/badge/Swift-5.3-brightgreen)](https://swift.org) [![Xcode Version](https://img.shields.io/badge/Xcode-12.1-success.svg)](https://swift.org) [![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](https://swift.org)

## Overview

The Virtual Tourist app downloads and stores images from Flickr. The app allows users to drop pins on a map, as if they were stops on a tour. Users will then be able to download pictures for the location and persist both the pictures, and the association of the pictures with the pin.

## Features

- Use MapKit
- Build an user interfaces with UIKit components
- Download data from public restful API ([Flickr API](https://www.flickr.com/services/api/))
- Data persistence on the device

## How to use the app

1. Launch the app using phone or iOS Simulator
2. App will starts with the map view. Users will be able to zoom and scroll around the map using standard pinch and drag gestures.
3. Tapping and holding the map drops a new pin. Users can place any number of pins on the map.
4. When a pin is tapped, the app will navigate to the Photo Album view associated with the pin.
5. If the user taps a pin that does not yet have a photo album, the app will download Flickr images associated with the latitude and longitude of the pin.
6. If there are images, then they will be displayed in a collection view and there is a New Collection button on the bottom.
6. Tapping the New Collection button should empty the photo album and fetch a new set of images.

## Tools

- Xcode 12.1
- Swift
 
## Compatibility

 - iOS 7+

## Installation

Download and unzip ```virtual-tourist```

## To Do

1. Add more entities to your Core Data model.
2. Implement a feature where the user can drag the pin they have just dropped on the map, but only until they lift their finger.
3. When the user drops the pin on the map, start downloading the images immediately without waiting for the user to navigate to the collection view.



