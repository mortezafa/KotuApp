// ContentView.swift

import SwiftUI
import AVFoundation


struct ContentView: View {
    var viewModel = PlayerViewModel()
    @State private var titleWord: String = ""
    @State private var leftButtonText: String = ""
    @State private var leftId: UUID = UUID()
    @State private var rightId: UUID = UUID()
    @State private var rightButtonText: String = ""
    @State private var hasSelected: Bool = false
    @State private var isLeftButtonCorrect: Bool? = nil
    @State private var isRightButtonCorrect: Bool? = nil
    @State private var addedToHistroy: Bool = false



    var body: some View {
        VStack {
            HistortyPatternView(viewModel: viewModel)
            Spacer()
            Text(titleWord)
                .padding(.bottom, 30)
                .font(.largeTitle)
            Button {
                Task {
                    await viewModel.repeatsound()
                }
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            .padding(10)
            .background(Color(white: 0.75))
            .clipShape(Capsule())

            Divider()
                .padding(.vertical)

            HStack {
                Button {
                    if !hasSelected {
                            addedToHistroy = true
                            let isCorrect = isCorrectWord(currentID: leftId, correctID: viewModel.getCorrectID())
                            isLeftButtonCorrect = isCorrect
                            isRightButtonCorrect = !isCorrect
                            hasSelected = true

                            if isCorrect {
                                viewModel.addToHistory(word: viewModel.pitchRepersentation(minimalPair: viewModel.fetchCorrectWord()), isCorrect: true)
                            } else {
                                viewModel.addToHistory(word: viewModel.pitchRepersentation(minimalPair: viewModel.fetchCorrectWord()), isCorrect: false)
                            }
                        } else {
                            Task{
                                if let isCorrect = isLeftButtonCorrect, isCorrect {
                                    await viewModel.repeatsound()
                                } else {
                                    await viewModel.playIncorrectSound()
                                }
                            }
                        }
                } label: {
                    Text(leftButtonText)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(isLeftButtonCorrect == true ? Color("correct") : (isLeftButtonCorrect == false ? Color("inCorrect") : Color.blue))

                Button {
                    if !hasSelected {
                            addedToHistroy = true
                            let isCorrect = isCorrectWord(currentID: rightId, correctID: viewModel.getCorrectID())
                            isLeftButtonCorrect = !isCorrect
                            isRightButtonCorrect = isCorrect
                            hasSelected = true

                            if isCorrect {
                                viewModel.addToHistory(word: viewModel.pitchRepersentation(minimalPair: viewModel.fetchCorrectWord()), isCorrect: true)
                            } else {
                                viewModel.addToHistory(word: viewModel.pitchRepersentation(minimalPair: viewModel.fetchCorrectWord()), isCorrect: false)
                            }
                        } else {
                            Task{
                                if let isCorrect = isRightButtonCorrect, isCorrect {
                                    await viewModel.repeatsound()
                                } else {
                                    await viewModel.playIncorrectSound()
                                }
                            }
                        }

                } label: {
                    Text(rightButtonText)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(isRightButtonCorrect == true ? Color("correct") : (isRightButtonCorrect == false ? Color("inCorrect") : Color.blue))
            }

            Divider()
                .padding(.vertical)

            Button {
                Task {
                    if hasSelected {
                        await viewModel.playMinimalPair()
                        titleWord = viewModel.fetchCorrectWord()

                        displayCorrectKanaUI(correctKana: viewModel.fetchCorrectKana(), incorrectKana: viewModel.fetchIncorrectKana())

                        isLeftButtonCorrect = nil
                        isRightButtonCorrect = nil
                        addedToHistroy = false
                        hasSelected = false
                    }
                    await viewModel.repeatsound()

                }
            } label: {
                Text("Continue")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            VStack(alignment: .leading) {
                PitchPatternsView(viewModel: viewModel)
            }
            .font(.title2)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .onAppear(perform: {
            Task{
                await viewModel.playMinimalPair()
                titleWord = viewModel.fetchCorrectWord()
                await viewModel.repeatsound()
                displayCorrectKanaUI(correctKana: viewModel.fetchCorrectKana(), incorrectKana: viewModel.fetchIncorrectKana())
            }
        })
    }
    func displayCorrectKanaUI(correctKana: String, incorrectKana: String) {
        let correctKana = viewModel.pitchRepersentation(minimalPair: correctKana)
        let incorrectKana = viewModel.pitchMisrepersentation(minimalPair: incorrectKana)
        let correctId = viewModel.getCorrectID()
        let randomNumber = Int.random(in: 1...2)
        if randomNumber == 1 {
            leftButtonText = correctKana
            leftId = correctId
            rightId = UUID()
            rightButtonText = incorrectKana
        } else {
            rightButtonText = correctKana
            rightId = correctId
            leftId = UUID()
            leftButtonText = incorrectKana
        }
    }


    func isCorrectWord(currentID: UUID, correctID: UUID) -> Bool {
        return currentID == correctID
    }
}


struct HistortyPatternView: View {
    @State var viewModel: PlayerViewModel
    @State private var historyPopup = false
    @State private var howtoPopup = false
    @State private var pattternPopup = false
    var body: some View {
        Button {
            howtoPopup.toggle()
        } label: {
            Image(systemName: "questionmark.circle.fill")
        }
        .font(.largeTitle)
        .fullScreenCover(isPresented: $howtoPopup, content: HowtoView.init)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.bottom)
        HStack {
            Button {
                historyPopup.toggle()
            } label: {
                Text("History")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)

            }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $historyPopup) {
                VStack {
                    List {
                        ForEach(viewModel.answerHistory.reversed()) { historyEntry in
                            HStack {
                                Text(historyEntry.word)
                                    .foregroundStyle(historyEntry.isCorrect ? Color("correct") : Color("inCorrect"))
                            }
                            .listRowBackground(historyEntry.isCorrect ? Color("correctHis") : Color("inCorrectHis"))
                        }
                    }
                    .frame(width: .infinity)
                }
                .presentationDetents([.medium, .large])
            }
            Button {
                pattternPopup.toggle()
            } label: {
                Text("Patterns")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $pattternPopup) {
                PatternView()
                    .presentationDetents([.height(400)])
            }
        }

    }
}

struct PitchPatternsView: View {
    @State var viewModel: PlayerViewModel
    private var numOfCorrect: Int { viewModel.answerHistory.filter { $0.isCorrect }.count
    }
    private var totalAttempts: Int { viewModel.answerHistory.count }

    private var percentage: String {
        guard totalAttempts > 0 else {
            return "0%"
        }
        let calculatedPercentage = (numOfCorrect * 100) / totalAttempts
        return "\(calculatedPercentage)%"
    }


    var body: some View {
        Divider()
            .padding(.vertical)
        HStack {
            Text("All")
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .background(.gray.opacity(0.7))
                .clipShape(Capsule())
            Spacer()
            Text("\(numOfCorrect) of \(totalAttempts) (\(percentage))")

        }
        HStack {
            Text("Heiban")
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .background(.blue.opacity(0.7))
                .clipShape(Capsule())
            Text("Odaka")
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .background(.green.opacity(0.7))
                .clipShape(Capsule())
            Spacer()
            Text("\(correctCount(pitchType:.heiban)) of \(totalCount(pitchType:.heiban)) (\(percentage(pitchType:.heiban)))")
        }
        HStack {
            Text("Atamadaka")
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .background(.red.opacity(0.7))
                .clipShape(Capsule())
            Spacer()
            Text("\(correctCount(pitchType:.atamadaka)) of \(totalCount(pitchType:.atamadaka)) (\(percentage(pitchType:.atamadaka)))")
        }
        HStack {
            Text("Nakadaka")
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .background(.orange.opacity(0.7))
                .clipShape(Capsule())
            Spacer()
            Text("\(correctCount(pitchType:.nakadaka)) of \(totalCount(pitchType:.nakadaka)) (\(percentage(pitchType:.nakadaka)))")
        }


    }
    func correctCount(pitchType: PitchAccentType) -> Int {
        viewModel.answerHistory.filter { $0.isCorrect && $0.pitchType == pitchType }.count
    }

    func totalCount(pitchType: PitchAccentType) -> Int {
        viewModel.answerHistory.filter { $0.pitchType == pitchType }.count
    }

    func percentage(pitchType: PitchAccentType) -> String {
        let totalAttempts = totalCount(pitchType: pitchType)

        guard totalAttempts > 0 else {
            return "0%"
        }

        let calculatedPercentage = (correctCount(pitchType: pitchType) * 100) / totalAttempts

        return "\(calculatedPercentage)%"
    }

}

#Preview {
    ContentView()
}
