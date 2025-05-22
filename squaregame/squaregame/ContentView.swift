import SwiftUI

struct Tile: Identifiable {
    let id = UUID()
    let color: Color
    var isRevealed: Bool = false
    var isMatched: Bool = false
}

class GameViewModel: ObservableObject {
    let totalRounds = 5
    let gridSize = 4
    let colorChoices: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan]
    
    @Published var grid: [Tile] = []
    @Published var revealedTiles: [Tile] = []
    @Published var message: String = ""
    @Published var roundScore: Int = 0
    @Published var totalScore: Int = 0
    @Published var round: Int = 1
    @Published var roundOver: Bool = false
    @Published var gameOver: Bool = false

    func startNewGame() {
        round = 1
        totalScore = 0
        gameOver = false
        startNewRound()
    }

    func startNewRound() {
        roundScore = 0
        message = ""
        roundOver = false
        revealedTiles = []
        generateGrid()
    }

    func generateGrid() {
        let totalTiles = gridSize * gridSize
        let pairsCount = totalTiles / 2
        let selectedColors = colorChoices.shuffled().prefix(pairsCount)
        let colorPool = Array(selectedColors + selectedColors).shuffled()
        grid = colorPool.map { Tile(color: $0) }
    }

    func tapTile(_ tile: Tile) {
        guard let index = grid.firstIndex(where: { $0.id == tile.id }),
              !grid[index].isRevealed,
              !grid[index].isMatched,
              !roundOver else { return }

        grid[index].isRevealed = true
        revealedTiles.append(grid[index])

        if revealedTiles.count == 2 {
            checkForMatch()
        }
    }

    func checkForMatch() {
        let first = revealedTiles[0]
        let second = revealedTiles[1]

        if first.color == second.color {
            if let firstIndex = grid.firstIndex(where: { $0.id == first.id }),
               let secondIndex = grid.firstIndex(where: { $0.id == second.id }) {
                grid[firstIndex].isMatched = true
                grid[secondIndex].isMatched = true
                roundScore += 1
                message = "Match Found"
            }

            revealedTiles = []

            if grid.allSatisfy({ $0.isMatched }) {
                totalScore += roundScore
                message = "Round Complete"
                roundOver = true

                if round == totalRounds {
                    gameOver = true
                    message = "Game Over – Total Score: \(totalScore)"
                }
            }
        } else {
            message = "Wrong Match – Round Over"
            roundOver = true
            revealedTiles = []

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.revealAll()
            }
        }
    }

    func revealAll() {
        for index in grid.indices {
            grid[index].isRevealed = true
        }
    }

    func nextRound() {
        if round < totalRounds {
            round += 1
            startNewRound()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Round \(viewModel.round) of \(viewModel.totalRounds)")
                .font(.title2)
            Text(viewModel.message)
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: viewModel.gridSize), spacing: 10) {
                ForEach(viewModel.grid) { tile in
                    Rectangle()
                        .foregroundColor(tile.isRevealed || tile.isMatched ? tile.color : .gray)
                        .frame(height: 60)
                        .cornerRadius(8)
                        .onTapGesture {
                            viewModel.tapTile(tile)
                        }
                }
            }
            .padding()

            Text("Round Score: \(viewModel.roundScore)")
            Text("Total Score: \(viewModel.totalScore)")

            if viewModel.roundOver && !viewModel.gameOver {
                Button("Next Round") {
                    viewModel.nextRound()
                }
                .padding()
            }

            if viewModel.gameOver {
                Button("Restart Game") {
                    viewModel.startNewGame()
                }
                .padding()
            }
        }
        .padding()
        .onAppear {
            viewModel.startNewGame()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
