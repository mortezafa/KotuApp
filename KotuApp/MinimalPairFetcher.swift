// MinimalPairFetcher.swift

import Foundation
import AVFoundation
import Observation

struct MinimalPairs: Decodable {
    struct Pair: Decodable {
        struct Entry: Decodable {
            struct Pronunciation: Decodable {
                struct Phrase: Decodable {
                    let rawPronunciation: String
                }

                let soundData: Data
                let phrases: [Phrase]
            }
            let pronunciations: [Pronunciation]
        }

        let id: UUID
        let pitchAccent: Int
        let entries: [Entry]
    }

    let kana: String
    let pairs: [Pair]
}

@Observable class KotuService {
    enum Error: Swift.Error {
        case invalidURL
        case invalidResponse
    }


    func randomMinimalPairs() async throws -> MinimalPairs {
        let url = URL(string: "https://kotu.io/api/tests/pitchAccent/minimalPairs/random")

        // Unwrap URL?
        guard let url else {
            throw Error.invalidURL
        }

        let session = URLSession.shared

        // Wait for result from session
        var request = URLRequest(url: url)
        request.setValue("Bearer \(Config.shared.apiKey)", forHTTPHeaderField: "Authorization")
        let result = try await session.data(for: request)

        // Unpack tuple
        let (data, response) = result

        // Cast the URLResponse to an HTTPURLResponse
        guard let response = response as? HTTPURLResponse else {
            print("cannot cast")
            throw Error.invalidResponse
        }

        // 3XX = redirect, 4XX = client error, 5XX = server error
        // 1XX = information, 2XX = success
        guard response.statusCode < 300 else {
            throw Error.invalidResponse
        }

        let decoder = JSONDecoder()
        let minimalPairs = try decoder.decode(MinimalPairs.self, from: data)
        
        return minimalPairs
    }
}

@Observable class PlayerViewModel {
    private let service = KotuService()
    private var player: AVAudioPlayer?

    var minimalPairs: MinimalPairs?
    var currentPair: MinimalPairs.Pair?
    var errorMessage: String?
    var wordTitle: String?

    func playMinimalPair() async {
        do {
            let fetchedPairs = try await service.randomMinimalPairs()

            minimalPairs = fetchedPairs

            guard let correctPair = fetchedPairs.pairs.randomElement() else {
                errorMessage = "No pair available."
                return
            }
            print(correctPair)

            currentPair = correctPair

        } catch {
            errorMessage = "Error occurred: \(error.localizedDescription)"
        }
    }
    
        func repeatsound() {
        guard let currentPair = currentPair else {
                    errorMessage = "No current pair to replay."
                    return
                }

                let data = currentPair.entries[0].pronunciations[0].soundData
                playSound(data: data)
    }

    func fetchCorrectWord() -> String {
        guard let word = minimalPairs?.kana else {
            errorMessage = "No word"
            return errorMessage!
        }
        return word
    }


     private func playSound(data: Data) {
        do {
            let player = try AVAudioPlayer(data: data)
            player.prepareToPlay()
            player.play()
            self.player = player
           } catch {
            errorMessage = "Error initializing AVAudioPlayer: \(error.localizedDescription)"
        }

    }
}


struct Config: Decodable {
    static let shared = {
        let url = Bundle.main.url(forResource: "config", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode(Config.self, from: data)
    } ()
    let apiKey: String
}

