//
//  MenuController.swift
//  OderApp
//
//  Created by Esperanza on 2022-01-31.
//

import Foundation
import UIKit

class MenuController {
    
    
    static let shared = MenuController()
    let baseURL = URL(string: "http://localhost:8080/")!


// request to /categories, with no query parameters, response JSON with an array of String.

func fetchCategories() async throws -> [String] {
    print(#function)
    let categoriesURL = baseURL.appendingPathComponent("categories")
    let (data, response) = try await URLSession.shared.data(from: categoriesURL)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw MenuControllerError.categoriesNotFound
    }
    
    let decoder = JSONDecoder()
    let categoriesResponse = try decoder.decode(CategoriesResponse.self, from: data)
    return categoriesResponse.categories
    
}

enum MenuControllerError: Error, LocalizedError {
    case categoriesNotFound
    case menuItemsNotFound
    case orderRequestFailed
    case imageDataMissing
}

// request to /menu, with one query parameter: the category string. JSON returned contains an array of dictionaries, deserialize each dictionary into a MenuItem object.

func fetchMenuItems(forCategory categoryName: String) async throws -> [MenuItem] {
    print(#function)
    let baseMenuURL = baseURL.appendingPathComponent("menu")
    var components = URLComponents(url: baseMenuURL, resolvingAgainstBaseURL: true)!
    components.queryItems = [URLQueryItem(name: "category", value: categoryName)]
    let menuURL = components.url!
    
    let (data, response) = try await URLSession.shared.data(from: menuURL)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw MenuControllerError.menuItemsNotFound
    }
    
    let decoder = JSONDecoder()
    let menuResponse = try decoder.decode(MenuResponse.self, from: data)
    return menuResponse.items
    
}

// post to /order. include the collection of menu item IDs that the user selected. response will be an integer specifying the number of minutes the order will take to prep.

typealias MinutesToPrePare = Int
func submitOrder(forMenuIDs menuIDs: [Int]) async throws -> MinutesToPrePare {
    let orderURL = baseURL.appendingPathComponent("order")
    var request = URLRequest(url: orderURL)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let menuIdsDict = ["menusIds": menuIDs]
    let jsonEnCoder = JSONEncoder()
    let jsonData = try? jsonEnCoder.encode(menuIdsDict)
    request.httpBody = jsonData
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw MenuControllerError.orderRequestFailed
    }
    
    let decoder = JSONDecoder()
    let orderResponse = try decoder.decode(OrderResponse.self, from: data)
    return orderResponse.prepTime
    
}
    var order = Order() {
        didSet {
            NotificationCenter.default.post(name: MenuController.orderUpdatedNotification, object: nil)
        }
    }
    static let orderUpdatedNotification = Notification.Name("MenuController.orderUpdated")
    
    
    // Request the image from server
    
    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.imageDataMissing
        }
        
        guard let image = UIImage(data: data) else {
            throw MenuControllerError.imageDataMissing
        }
        
        return image
    }
    
    
    
}
