//
//  APILayer.swift
//  DeckofCards
//
//  Created by Layne Hunt on 5/2/21.
//

import Foundation

struct Deck: Codable {
    let deck_id: String
    var remaining: Int
    
    func shuffle() {
        let url = URL(string: "https://deckofcardsapi.com/api/deck/\(deck_id)/shuffle/")!
        
        getData(from: url, type: Deck.self, completion: nil)
    }
    
    func drawEasy(completion: @escaping (CardInfo) -> Void) {
        let url = URL(string: "https://deckofcardsapi.com/api/deck/\(deck_id)/draw/?count=6")!
        
        getData(from: url, type: CardInfo.self, completion: completion)
    }
    //These two functions drawMed and drawHard can be incorperated later when the feature of adding more cards displayed on the screen becomes available. They are not being used now.
    func drawMed(completion: @escaping (CardInfo) -> Void) {
        let url = URL(string: "https://deckofcardsapi.com/api/deck/\(deck_id)/draw/?count=10")!
        
        getData(from: url, type: CardInfo.self, completion: completion)
    }
    
    func drawHard(completion: @escaping (CardInfo) -> Void) {
        let url = URL(string: "https://deckofcardsapi.com/api/deck/\(deck_id)/draw/?count=12")!
        
        getData(from: url, type: CardInfo.self, completion: completion)
    }
    
}

struct CardInfo: Codable {
    let cards: [Card]
    let remaining: Int
}

struct Card: Codable {
    let image: String
    let value: String
    let suit: String
    let code: String
}

func getData<T: Codable>(from url: URL, type: T.Type, completion: ((T) -> Void)?) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            let decoder = JSONDecoder()
            
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                if let completion = completion {
                    completion(decodedData)
                }
            } catch {
                print(error.localizedDescription)
                
                
                
            }
        }
        
    }.resume()
    
}

