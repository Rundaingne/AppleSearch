//
//  AppStoreItemController.swift
//  AppleSearch
//
//  Created by Brooke Kumpunen on 3/21/19.
//  Copyright © 2019 Rund LLC. All rights reserved.
//

import Foundation

class AppStoreItemController {
    
   static let baseUrl = URL(string: "https://itunes.apple.com")
    
    static func fetchItemsOf(type: AppStoreItem.ItemType, searchTerm: String, completion: @escaping ([AppStoreItem]?) -> Void) {
        
        //Create the url
        guard let url = baseUrl?.appendingPathComponent("search"),
         var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {completion(nil); return}
        //Append to this url some stuff. And also chunk it into its components. We are going to want to add a component for search, and then some query items, and then a path extension of "json".
        let querySearchTermItem = URLQueryItem(name: "term", value: searchTerm)
        let queryItemType = URLQueryItem(name: "entity", value: type.rawValue)
        components.queryItems = [queryItemType, querySearchTermItem] //Insert into this array querySearchTermItem, and queryItemType
        guard let finalUrl = components.url else {completion(nil); return}
        
        //Call dataTask.
        URLSession.shared.dataTask(with: finalUrl) { (data, _, error) in
            if let error = error {
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(nil)
                return
            }
            guard let data = data else {completion(nil); return}
            //If we get to this point, we have data. Since we aren't using codable, this part will change.
            do {
                guard let topLevelDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let resultsArray = topLevelDictionary["results"] as? [[String: Any]] else {completion(nil); return}
                let appStoreItems = resultsArray.compactMap{ AppStoreItem(itemType: type, dictionary: $0)}
                completion(appStoreItems)
            } catch {
                print("There was an error in \(#function): \(error) \(error.localizedDescription)")
                completion(nil)
                return
            }
        }
    }
}
