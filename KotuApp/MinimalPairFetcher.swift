
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
enum Error: Swift.Error {
    case invalidURL
    case invalidResponse
}



@Observable class KotuService {
    static let shared = KotuService()


    var checkedHeibanOdaka = true
    var checkedAtamadaka = true
    var checkedNakaDaka1 = true
    var checkedNakaDaka2 = true
    var checkedNakaDaka3 = true

    private init() {}

    func randomMinimalPairs() async throws -> MinimalPairs {
        guard let url = URL(string: "https://kotu.io/api/tests/pitchAccent/minimalPairs/random?heibanEnabled=\(checkedHeibanOdaka)&atamadakaEnabled=\(checkedAtamadaka)&secondMoraAccentEnabled=\(checkedNakaDaka1)&secondToLastMoraAccentEnabled=true&otherNakadakaEnabled=\(checkedNakaDaka3)&onlyDevoicedWords=false") else {
            throw Error.invalidURL
        }
        print(url)

        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.setValue("Bearer \(Config.shared.apiKey)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
                print("Failed response or bad status code")
                throw Error.invalidResponse
            }

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

    struct Answers: Identifiable {
        let id = UUID()
        let word: String
        let isCorrect: Bool
        let pitchType: PitchAccentType
    }

    private let service = KotuService.shared
    private var player: AVAudioPlayer?
    var answerHistory: [Answers] = []
    var minimalPairs: MinimalPairs?
    var correctpair: MinimalPairs.Pair?
    var incorrectPair: MinimalPairs.Pair?
    var errorMessage: String?
    var wordTitle: String?
    private var potentialAccents = [0...10]

    func playMinimalPair() async {
        do {
            let fetchedPairs = try await service.randomMinimalPairs()

            minimalPairs = fetchedPairs

            guard let correctPair = fetchedPairs.pairs.randomElement() else {
                errorMessage = "No pair available."
                return
            }

            correctpair = correctPair

            incorrectPair = fetchedPairs.pairs.filter { $0.pitchAccent != correctPair.pitchAccent }.randomElement()


        } catch {
            errorMessage = "Error occurred: \(error.localizedDescription)"
        }
    }

    func repeatsound() async {
        guard let currentPair = correctpair else {
            errorMessage = "No current pair to replay."
            return
        }

        let data = currentPair.id
        await playSound(data: data)
    }

    func playIncorrectSound() async {
        guard let currentPair = incorrectPair else {
            errorMessage = "No current pair to replay."
            return
        }

        let data = currentPair.id
        await playSound(data: data)
    }

    func fetchCorrectWord() -> String {
        guard let word = minimalPairs?.kana else {
            errorMessage = "No word"
            return errorMessage!
        }
        return word
    }

     func fetchCorrectKana() -> String {
        guard let correctKana = correctpair?.entries[0].pronunciations[0].phrases[0].rawPronunciation else {
            return "no correct Kana"
        }
        return correctKana
    }

     func fetchIncorrectKana() -> String {
        guard let incorrectKana = incorrectPair?.entries[0].pronunciations[0].phrases[0].rawPronunciation else {
            return "no incorrect Kana"
        }
        return incorrectKana
    }

    func getCorrectID() -> UUID {
        guard let correctId = correctpair?.id else { return UUID() }
        return correctId
    }

    private func splitIntoMoras(text: String) -> [String] {
        let smallKana: Set<Character> = ["ァ", "ィ", "ゥ", "ェ", "ォ", "ャ", "ュ", "ョ"]
        var moras: [String] = []
        let characters = Array(text)

        var index = 0
        while index < characters.count {
            let char = characters[index]

            // If its the last character or the next character is not a small kana, its a single mora.
            if index == characters.count - 1 || !smallKana.contains(characters[index + 1]) {
                moras.append(String(char))
                index += 1
            } else {
                // The next character is a small kana so we can just combine them into a single mora.
                let nextChar = characters[index + 1]
                moras.append(String(char) + String(nextChar))
                index += 2
            }
        }
        return moras
    }

    func pitchRepersentation(minimalPair: String) -> String {
        guard let pitchAccent = correctpair?.pitchAccent else {
            return "No pair"
        }
        var moras = splitIntoMoras(text: minimalPair)
        print(" Here are the moras: \(moras)")
        
        if pitchAccent >= 1 {
            moras.insert("＼", at: pitchAccent)
        }
        let pitchRepersentedWord = moras.joined()
        return pitchRepersentedWord
    }

    func pitchMisrepersentation(minimalPair: String) -> String {
        var moras = splitIntoMoras(text: minimalPair)
        print(" Here are the moras: \(moras)")
        var pitchRepersentedWord = ""

        guard let pitchAccent = incorrectPair?.pitchAccent else {
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

    private func playSound(data: UUID) async {
            do {
                let player = try await AVAudioPlayer(data: fetchAudioData(moraId: data))
                player.prepareToPlay()
                player.play()
                self.player = player
               } catch {
                errorMessage = "Error initializing AVAudioPlayer: \(error.localizedDescription)"
            }
    
        }

    func addToHistory(word: String, isCorrect: Bool) {
        let answer = Answers(word: word, isCorrect: isCorrect, pitchType: getPitchType())
        answerHistory.append(answer)
        print(answerHistory)
    }

    private func fetchAudioData(moraId: UUID) async throws -> Data {
        guard let url = URL(string: "https://kotu.io/api/pronunciation/audio/\(moraId)?lowPass=false&backgroundNoise=false") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return data
    }

    func getPitchType() -> PitchAccentType {
        if correctpair?.pitchAccent == 0 {
            return .heiban
        } else if correctpair?.pitchAccent == 1 {
            return .atamadaka
        }

        return .nakadaka
    }

}
enum PitchAccentType {
    case heiban // we treat heiban and odaka as the same so no need for another case
    case atamadaka
    case nakadaka
}

struct Config: Decodable {
    static let shared = {
        let url = Bundle.main.url(forResource: "config", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode(Config.self, from: data)
    } ()
    let apiKey: String
}

