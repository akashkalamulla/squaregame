// SwiftUI Color Matching Game
// Created May 25, 2025

import SwiftUI

struct Tile: Identifiable {
    let id = UUID()
    var color: Color
    var isMatched: Bool = false
}

struct RoundRecord: Identifiable, Codable {
    let id = UUID()
    let round: Int
    let matches: Int
    let score: Int
}

struct PlayerData: Codable {
    var name: String
    var history: [RoundRecord]
}

struct ContentView: View {
    @AppStorage("playerName") private var playerName: String = ""
    @State private var showNamePrompt = true
    @State private var tiles: [Tile] = []
    @State private var selectedTile: UUID? = nil
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var level = 1
    @State private var matchesThisRound = 0
    @State private var totalMatches = 0
    @State private var gameOver = false
    @State private var gameStarted = false
    @State private var tileCount = 18
    @State private var roundHistory: [RoundRecord] = []

    let matchGoal = 10
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            Text("Player: \(playerName)").font(.title2)
            Text("Level \(level)").font(.largeTitle)
            Text("Time: \(timeRemaining)")
            Text("Score: \(score)")
            Text("Matches: \(matchesThisRound)/\(matchGoal)")
            Text("Total Matches: \(totalMatches)")

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

            if !roundHistory.isEmpty {
                VStack(alignment: .leading) {
                    Text("Game History").font(.headline)
                    ForEach(roundHistory) { round in
                        Text("Round \(round.round): Matches = \(round.matches), Score = \(round.score)")
                            .font(.subheadline)
                    }
                }
                .padding()
            }
        }
        .padding()
        .onAppear {
            loadPlayerData()
        }
        .onReceive(timer) { _ in
            if gameStarted && timeRemaining > 0 {
                timeRemaining -= 1
            } else if gameStarted {
                endGame()
            }
        }
        .alert("Enter Player Name", isPresented: $showNamePrompt, actions: {
            TextField("Player Name", text: $playerName)
            Button("OK") {
                savePlayerData()
            }
        }, message: {
            Text("Please enter your name to start the game")
        })
        .alert(isPresented: $gameOver) {
            Alert(
                title: Text("Game Complete!"),
                message: Text("Player: \(playerName)\nScore: \(score)\nTotal Matches: \(totalMatches)"),
                dismissButton: .default(Text("OK")) {
                    playerName = ""
                    showNamePrompt = true
                }
            )
        }
    }

    func startGame() {
        gameStarted = true
        score = 0
        timeRemaining = 30
        gameOver = false
        level = 1
        matchesThisRound = 0
        totalMatches = 0
        tileCount = 18
        roundHistory = []
        generateTiles()
    }

    func endGame() {
        gameOver = true
        gameStarted = false
        roundHistory.append(RoundRecord(round: level, matches: matchesThisRound, score: score))
        savePlayerData()
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
                totalMatches += 1

                if matchesThisRound >= matchGoal {
                    roundHistory.append(RoundRecord(round: level, matches: matchesThisRound, score: score))
                    let bonusTime = max(0, timeRemaining - 5)
                    score += bonusTime
                    level += 1
                    timeRemaining = 30 + (bonusTime > 0 ? 10 : 0)
                    tileCount += 2
                    matchesThisRound = 0
                    generateTiles()
                } else if tiles.allSatisfy({ $0.isMatched }) {
                    generateTiles()
                }
            }
            selectedTile = nil
        } else {
            selectedTile = tile.id
        }
    }

    func savePlayerData() {
        let data = PlayerData(name: playerName, history: roundHistory)
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "player_\(playerName)")
        }
    }

    func loadPlayerData() {
        if let savedData = UserDefaults.standard.data(forKey: "player_\(playerName)"),
           let loaded = try? JSONDecoder().decode(PlayerData.self, from: savedData) {
            roundHistory = loaded.history
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
