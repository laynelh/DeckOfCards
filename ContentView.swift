//
//  ContentView.swift
//  Shared
//
//  Created by Layne Hunt on 5/2/21.
//

import SwiftUI

class DeckModel: ObservableObject {
    //this model layer works to keep track of the points a user accumulates so that each time they close the app and reopen it, their progress will remain. This helps add another layer of gamification to the app.
    @Published var points: Int {
        didSet {
            UserDefaults.standard.set((points), forKey: "points")
        }
    }
    @Published var difficulty: Int {
        didSet {
            UserDefaults.standard.set((difficulty), forKey: "difficulty")
        }
    }
    init() {
        points = UserDefaults.standard.integer(forKey: "points")
        difficulty = UserDefaults.standard.integer(forKey: "difficulty")
    }
}

struct ContentView: View {
    @ObservedObject var deckModel = DeckModel()
    @State var data: Deck?
    //I needed to create an empty array of cards in order to store the AIP information in something that could be passed down through views and manipulated later.
    @State var currentHand: [Card] = [
        
    ]
    //These two arrays appear in the ContentView rather than in the CardAreaView or CardForEachView because when a new deck is created I needed to be able to flip all the items in the locked array back to false. The only way I could do this is by adding that command to the .onTapGesture code on lines 84-97
    @State var flipped = [
        false, false, false, false, false, false, false, false, false, false, false, false
    ]
    @State var locked = [
        false, false, false, false, false, false, false, false, false, false, false, false
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("casinoPurple").ignoresSafeArea()
                VStack {
                    HStack{
                        Text("\(data?.remaining ?? 0) cards remaining in deck")
                            .font(.title2)
                            .foregroundColor(Color.white)
                            .bold()
                            .padding()
                            .onAppear {
                                let urlString = URL(string: "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1")!
                                getData(from: urlString, type: Deck.self) { data in
                                    self.data = data
                                }
                            }
                        // incorperate this Z Stack if you decide to include a timer feature so that the player can get maximum amount of unique cards within a time limit
                        //                        ZStack {
                        //                            RoundedRectangle(cornerRadius: 15)
                        //                                .frame(width: 180, height: 40, alignment: .center)
                        //                                .foregroundColor(Color("lightGray"))
                        //                            Text("SHUFFLE THE DECK")
                        //                                .font(.headline)
                        //                                .foregroundColor(Color.white)
                        //                                .onTapGesture {
                        //                                    data?.shuffle()
                        //                                    data?.remaining = 52
                        //                                }
                        //                        }
                    }
                    Spacer()
                    CardAreaView(deckModel: deckModel, currentHand: $currentHand, data: $data, flipped: $flipped, locked: $locked)
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 330, height: 90, alignment: .center)
                            .foregroundColor(Color("lightGray"))
                        Text("Get New Deck")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(Color.white)
                            .onTapGesture {
                                data?.drawEasy() { (data: CardInfo) in
                                    data.cards.forEach { card in
                                        currentHand.append(card)
                                        currentHand.append(card)
                                        
                                    }
                                    currentHand.shuffle()
                                    self.data = Deck(deck_id: self.data!.deck_id, remaining: data.remaining )
                                    locked = [
                                        false, false, false, false, false, false, false, false, false, false, false, false
                                    ]
                                }
                            }
                    }
                }.navigationBarItems(leading: NavigationLink(
                                        destination: MenuView(deckModel: deckModel, selectedDifficulty: $deckModel.difficulty),
                                        label: {
                                            Image(systemName: "chart.bar.doc.horizontal")
                                                .resizable()
                                                .foregroundColor(Color("lightGray"))
                                                .frame(width: 30, height: 30, alignment: .center)
                                                .padding()
                                        }), trailing: Text("Match the Cards!   POINTS: \(deckModel.points)")
                                            .foregroundColor(Color.white)
                                            .font(.subheadline)
                                            .padding())
            }
        }
    }
}

//I needed to create another struct to hold the CardForEachView because the geometry reader could not be incorperated into that view since it only returns one item.
struct CardAreaView: View {
    @ObservedObject var deckModel: DeckModel
    @Binding var currentHand: [Card]
    @Binding var data: Deck?
    
    @Binding var flipped: [Bool]
    @Binding var locked: [Bool]
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                CardForeachView(deckModel: deckModel, currentHand: $currentHand, data: $data, flipped: $flipped, locked: $locked, geoProxy: geo)
                
            }
            .padding()
        }
    }
}

struct CardForeachView: View {
    @ObservedObject var deckModel: DeckModel
    @Binding var currentHand: [Card]
    @Binding var data: Deck?
    
    @Binding var flipped: [Bool]
    @Binding var locked: [Bool]
    
    @State var codeMatch: [String] = [
    ]
    @State var matchedCardIndex: [Int] = [
    ]
    var geoProxy: GeometryProxy
    
    //In the future, include an if statement and calculate offsets and row numbers depending on how many cards the user wants to be displayed.
    var rowNumber = 3
    var columnNumber = 4
    var xOffset = 90
    var yOffset = 2
    var difficulty = 0
    
    func codeFor(_ row: Int, _ col: Int) -> String {
//        print(row, col, row*columnNumber+col, currentHand.count)
        return row*columnNumber+col < currentHand.count ? currentHand[row*columnNumber+col].code : "\(row*columnNumber+col)"
    }
    
    var body: some View {
        
        let frame = geoProxy.frame(in: .local)
        let leftPadding = (Int(frame.width) - (7 * 40 + 10 * 6))/2
        
        if currentHand.count < 12 {
            return AnyView(Text("Draw Some Cards!!!").padding().foregroundColor(Color.secondary).font(.title))
        } else {
            return AnyView(ForEach(0..<rowNumber, id: \.self) { row in
                ForEach(0..<columnNumber, id: \.self){ column in
                    CardView(
                        deckModel: deckModel, flipped: $flipped, locked: $locked, codeMatch: $codeMatch, matchedCardIndex: $matchedCardIndex, code: codeFor(row, column), cardIndex: (row*columnNumber+column), initialLocation: CGPoint(x: column * xOffset + leftPadding, y: row * yOffset - (column*40))
                    )
                }
            })
        }
    }
}

struct CardView: View {
    @ObservedObject var deckModel: DeckModel
    @State var location = CGPoint(x: 0, y: 0)
    
    var cardsFlipped: Int {
        var count = 0
        for card in flipped {
            if card == true {
                count += 1
            }
        }
        return count
    }
    
    @Binding var flipped: [Bool]
    @Binding var locked: [Bool]
    
    @Binding var codeMatch: [String]
    @Binding var matchedCardIndex: [Int]
    
    var code: String
    var cardIndex: Int
    
    var cardWidth = 76
    var cardHieght = 100
    
    let initialLocation: CGPoint
    
    var width: CGFloat = 76
    var height: CGFloat = 100
    
    func revertCards() {
        for i in flipped.indices {
            flipped[i] = false
        }
    }
    
    var body: some View {
        
        Image(flipped[cardIndex] || locked[cardIndex] ? "\(self.code)" : "cardBack")
            .resizable()
            .frame(width: width, height: height, alignment: .center)
            //I was able to find a tutorial on how to code a flipping animation in swift from the website: https://medium.com/@bradysmurphy/day-16-swiftui-card-flip-animation-6ebe1de26a48
            //I will modify their code to match my needs for my matching game, including adding images instead of colors and a timer that flips the card after another was chosen that was not a match.
            .rotation3DEffect(flipped[cardIndex] ? Angle(degrees: 360): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
            .onTapGesture {
                //There is a bug here: when the user taps on the same card twice, it mistakes it as a match and unsyncronizes the locked array. Needs to be addressed in the future.
                if cardsFlipped == 0 {
                    codeMatch.append("\(code)")
                    flipped[cardIndex] = true
                    //                        print("\(cardsFlipped)")
                } else if cardsFlipped == 1 {
                    codeMatch.append("\(code)")
                    flipped[cardIndex] = true
                    //this code determines if the two flipped cards are matches and then locks both cards in place.
                    if codeMatch[0] == codeMatch[1] {
                        if let indexFirst = flipped.firstIndex(of: true) {
                            locked[indexFirst] = true
                            flipped[indexFirst] = false
                        }
                        if let indexLast = flipped.lastIndex(of: true) {
                            locked[indexLast] = true
                            flipped[indexLast] = false
                        }
                        deckModel.points += 1
                        codeMatch = []
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        revertCards()
                    }
                    codeMatch = []
                }
                //                    print("\(codeMatch)")
                //                    print("\(cardsFlipped)")
                //                    print("\(flipped)")
                //                    print("\(locked)")
            }
            .position(location)
            .animation(.default)
            .onAppear(perform: {
                location = initialLocation
            })
            .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
