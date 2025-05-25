// SwiftUI Color Matching Game
// Created May 25, 2025

import SwiftUI

struct Tile: Identifiable {
    let id = UUID()
    var color: Color
    var isMatched: Bool = false
}

struct ContentView: View {
    @State private var tiles: [Tile] = []
    @State private var selectedTile: UUID? = nil
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var level = 1
    @State private var gameOver = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            Text("Level \(level)").font(.largeTitle)
            Text("Time: \(timeRemaining)")
            Text("Score: \(score)")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(tiles) { tile in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(tile.color.opacity(tile.isMatched ? 0.3 : 1.0))
                        .frame(height: 100)
                        .onTapGesture {
                            handleTap(on: tile)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                }
            }
            .padding()

            HStack(spacing: 20) {
                Button("Next Level") {
                    nextLevel()
                }
                .disabled(!gameOver)

                Button("Reset Game") {
                    startGame()
                }
            }
            .padding()
        }
        .padding()
        .onAppear(perform: startGame)
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                gameOver = true
            }
        }
        .alert(isPresented: $gameOver) {
            Alert(title: Text("Time's up!"), message: Text("Your score: \(score)"), dismissButton: .default(Text("OK")))
        }
    }

    func startGame() {
        score = 0
        timeRemaining = 30
        gameOver = false
        level = 1
        generateTiles()
    }

    func nextLevel() {
        level += 1
        timeRemaining = 30
        gameOver = false
        generateTiles()
    }

    func generateTiles() {
        tiles.removeAll()
        let baseColors = [Color.red, Color.green, Color.blue, Color.orange, Color.purple, Color.yellow].shuffled()
        let pairColors = Array(baseColors.prefix(2))
        let allColors = (pairColors + pairColors).shuffled()
        tiles = allColors.map { Tile(color: $0) }
        selectedTile = nil
    }

    func handleTap(on tile: Tile) {
        guard !tile.isMatched, !gameOver else { return }

        if let firstID = selectedTile, let firstIndex = tiles.firstIndex(where: { $0.id == firstID }), let secondIndex = tiles.firstIndex(where: { $0.id == tile.id }) {
            if tiles[firstIndex].color == tiles[secondIndex].color {
                tiles[firstIndex].isMatched = true
                tiles[secondIndex].isMatched = true
                score += 10
            }
            selectedTile = nil
        } else {
            selectedTile = tile.id
        }
    }
}

// MARK: – Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
