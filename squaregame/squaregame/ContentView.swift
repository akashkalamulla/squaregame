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
    @State private var matchesThisRound = 0
    @State private var gameOver = false
    @State private var gameStarted = false
    @State private var tileCount = 18 // 3x3 grid = 9 tiles → 4 pairs + 1 extra
    let matchGoal = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            Text("Level \(level)").font(.largeTitle)
            Text("Time: \(timeRemaining)")
            Text("Score: \(score)")
            Text("Matches: \(matchesThisRound)/\(matchGoal)")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: Int(sqrt(Double(tileCount)))), spacing: 16) {
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

            Button(gameStarted ? "Restart Game" : "Start Game") {
                startGame()
            }
            .padding()
        }
        .padding()
        .onReceive(timer) { _ in
            if gameStarted && timeRemaining > 0 {
                timeRemaining -= 1
            } else if gameStarted {
                gameOver = true
                gameStarted = false
            }
        }
        .alert(isPresented: $gameOver) {
            Alert(title: Text("Game Complete!"), message: Text("Your score: \(score)"), dismissButton: .default(Text("OK")))
        }
    }

    func startGame() {
        gameStarted = true
        score = 0
        timeRemaining = 30
        gameOver = false
        level = 1
        matchesThisRound = 0
        tileCount = 18
        generateTiles()
    }

    func generateTiles() {
        tiles.removeAll()
        let gridSize = Int(sqrt(Double(tileCount)))
        let baseColors = [Color.red, Color.green, Color.blue, Color.orange, Color.purple, Color.yellow, Color.pink, Color.gray, Color.teal].shuffled()
        let pairCount = tileCount / 2
        var allColors = Array(baseColors.prefix(pairCount)).flatMap { [ $0, $0 ] }.shuffled()

        if allColors.count < tileCount {
            allColors.append(baseColors[pairCount % baseColors.count])
        }

        tiles = allColors.prefix(tileCount).map { Tile(color: $0) }
        selectedTile = nil
    }

    func handleTap(on tile: Tile) {
        guard !tile.isMatched, !gameOver else { return }

        if let firstID = selectedTile, let firstIndex = tiles.firstIndex(where: { $0.id == firstID }), let secondIndex = tiles.firstIndex(where: { $0.id == tile.id }) {
            if tiles[firstIndex].color == tiles[secondIndex].color {
                tiles[firstIndex].isMatched = true
                tiles[secondIndex].isMatched = true
                score += 10
                matchesThisRound += 1

                if matchesThisRound >= matchGoal {
                    let bonusTime = max(0, timeRemaining - 5)
                    score += bonusTime
                    level += 1
                    timeRemaining = 30 + (bonusTime > 0 ? 10 : 0)
                    tileCount += 2
                    matchesThisRound = 0
                    generateTiles()
                } else if tiles.allSatisfy({ $0.isMatched }) {
                    // Generate a new board to continue matching
                    generateTiles()
                }
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
