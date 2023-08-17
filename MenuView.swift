//
//  MenuView.swift
//  DeckofCards
//
//  Created by Layne Hunt on 5/10/21.
//

import Foundation
import SwiftUI


struct MenuView: View {
    @ObservedObject var deckModel: DeckModel
    @Binding var selectedDifficulty: Int
    
    var body: some View {
        ZStack {
            Color("casinoRed").ignoresSafeArea()
            VStack{
                Text("Select Card Amount")
                    .font(.title)
                    .foregroundColor(Color.white)
                    .bold()
                DifficultyPicker(deckModel: deckModel, selectedDifficulty: $selectedDifficulty)
                Text("This app currently only has one card number setting")
                    .foregroundColor(Color.white)
                    .font(.body)
                    .padding()
                Spacer()
                Text("More Games Soon to Come!")
                    .foregroundColor(Color.white)
                    .font(.caption)
                    .padding()
            }
        }
    }
}

struct DifficultyPicker: View {
    @ObservedObject var deckModel: DeckModel
    @Binding var selectedDifficulty: Int
    
    var level = ["12"]
    
    var body: some View {
        VStack{
            Picker(selection: $selectedDifficulty, label: Text("Select Card Amount")) {
                ForEach(0..<level.count) {
                    Text(self.level[$0])
                        .font(.title2)
                        .foregroundColor(Color.white)
                        .bold()
                }
            }
        }
    }
}


