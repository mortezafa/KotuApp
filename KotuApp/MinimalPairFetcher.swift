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

                let soundFile: String
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
        guard let url = URL(string: "https://kotu.io/api/tests/pitchAccent/minimalPairs/random?heibanEnabled=true&atamadakaEnabled=true&secondMoraAccentEnabled=true&secondToLastMoraAccentEnabled=true&otherNakadakaEnabled=true&onlyDevoicedWords=false") else {
            throw Error.invalidURL
        }

        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.setValue("Bearer \(Config.shared.apiKey)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
                print("Failed response or bad status code")
                throw Error.invalidResponse
            }

            print("Data received: \(data.count) bytes")  // Log the size of the data

            let decoder = JSONDecoder()
            do {
                let minimalPairs = try decoder.decode(MinimalPairs.self, from: data)
                return minimalPairs
            } catch {
                print("Decoding error: \(error)")  // Log decoding error
                throw error
            }
        } catch {
            print("Network or URL error: \(error)")  // Log other errors
            throw error
        }
    }
}



@Observable class PlayerViewModel {
//    static let shared = PlayerViewModel()

    struct Answers: Identifiable {
        let id = UUID()
        let word: String
        let isCorrect: Bool
    }

    private let service = KotuService()
    private var player: AVAudioPlayer?
    var answerHistory: [Answers] = []
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
            print("THIS IS THE CORRECT PAIR \(correctPair) ")

            currentPair = correctPair
            let pitchAccentOfCorrectPair = currentPair?.pitchAccent

            print("THIS IS THE PITCH OF THE CORRECT PAIR", pitchAccentOfCorrectPair!)

        } catch {
            errorMessage = "Error occurred: \(error.localizedDescription)"
        }
    }

    func repeatsound() {
        guard let currentPair = currentPair else {
            errorMessage = "No current pair to replay."
            return
        }

        let data = currentPair.entries[0].pronunciations[0].soundFile
        //                playSound(data: data)
    }

    func fetchCorrectWord() -> String {
        guard let word = minimalPairs?.kana else {
            errorMessage = "No word"
            return errorMessage!
        }
        return word
    }


    private func fetchCorrectKana() -> String {
        guard let correctKana = currentPair?.entries[0].pronunciations[0].phrases[0].rawPronunciation else {
            return "no correct Kana"
        }
        return correctKana
    }

    func getCorrectID() -> UUID {
        guard let correctId = currentPair?.id else { return UUID() }
        return correctId
    }

    private func splitIntoMoras(text: String) -> [String] {
        let smallKana: Set<Character> = ["ァ", "ィ", "ゥ", "ェ", "ォ", "ャ", "ュ", "ョ", "ッ"]
        var moras: [String] = []
        let characters = Array(text)

        var index = 0
        while index < characters.count {
            let char = characters[index]

            //if its the last character or the next character is not a small kana, its a single mora.
            if index == characters.count - 1 || !smallKana.contains(characters[index + 1]) {
                moras.append(String(char))
                index += 1
            } else {
                //the next character is a small kana so we can jusy combine them into a single mora.
                let nextChar = characters[index + 1]
                moras.append(String(char) + String(nextChar))
                index += 2
            }
        }

        return moras
    }

    func pitchRepersentation() -> String {
        var moras = splitIntoMoras(text: fetchCorrectKana())
        print(" Here are the moras: \(moras)")
        var pitchRepersentedWord = ""
        guard let pitchAccent = currentPair?.pitchAccent else {
            return "No pair"
        }

        if pitchAccent == 0 {
            pitchRepersentedWord = moras.joined()
        } else if pitchAccent == 1 {
            moras.insert("＼", at: 1)
            pitchRepersentedWord = moras.joined()
        } else if pitchAccent > 1 {
            moras.insert("＼", at: pitchAccent)
            pitchRepersentedWord = moras.joined()
        }

        return pitchRepersentedWord
    }

    func pitchMisrepresentation() -> String {
        let moras = splitIntoMoras(text: fetchCorrectKana())
        guard let pitchAccent = currentPair?.pitchAccent else {
            return "No pair or insufficient moras"
        }

        var pitchMisrepresentedWord = ""
        var randomIndex = Int.random(in: 0..<moras.count)

        var validIndices = [Int]()


        for index in 1..<moras.count {
            if moras[index] != "ン" && index != pitchAccent {
                if moras[index - 1] != "ン"  {
                    validIndices.append(index)
                }
            }
        }

        print(validIndices)


        var modifiedMoras = moras

        if validIndices.count == 0 {
            modifiedMoras.insert("＼", at: moras.count)
        }

        modifiedMoras.insert("＼", at: randomIndex)
        pitchMisrepresentedWord = modifiedMoras.joined()

        print(modifiedMoras)
        return pitchMisrepresentedWord
    }

    //     private func playSound(data: String) {
    //        do {
    //            let player = try AVAudioPlayer(data: data)
    //            player.prepareToPlay()
    //            player.play()
    //            self.player = player
    //           } catch {
    //            errorMessage = "Error initializing AVAudioPlayer: \(error.localizedDescription)"
    //        }
    //
    //    }

    func addToHistory(word: String, isCorrect: Bool) {
        let answer = Answers(word: word, isCorrect: isCorrect)
        answerHistory.append(answer)
        print(answerHistory)
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

