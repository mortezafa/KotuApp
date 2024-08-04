// ContentView.swift

import SwiftUI
import AVFoundation

struct ContentView: View {

    let viewModel = PlayerViewModel()

    @State private var titleWord = ""
    @State private var leftButtonText = ""
    @State private var leftId = UUID()
    @State private var rightId = UUID()
    @State private var rightButtonText = ""
    @State private var hasSelected = false
    @State private var isLeftButtonCorrect: Bool? = nil
    @State private var isRightButtonCorrect: Bool? = nil
    @State private var addedToHistroy = false

    var content: some View {
        VStack {
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
                        Task {
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

                        display(correctKana: viewModel.fetchCorrectKana(), incorrectKana: viewModel.fetchIncorrectKana())

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
            Task {
                await viewModel.playMinimalPair()
                titleWord = viewModel.fetchCorrectWord()
                await viewModel.repeatsound()
                display(correctKana: viewModel.fetchCorrectKana(), incorrectKana: viewModel.fetchIncorrectKana())
            }
        })
    }

    @State private var historyPopup = false
    @State private var howtoPopup = false
    @State private var pattternPopup = false

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("History") {
                            historyPopup.toggle()
                        }
                    }

                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Settings", systemImage: "gearshape") {
                            pattternPopup.toggle()
                        }
                        Button("Info", systemImage: "info.circle") {
                            howtoPopup.toggle()
                        }
                    }
                }
                .fullScreenCover(isPresented: $howtoPopup, content: HowtoView.init)
                .sheet(isPresented: $historyPopup) {
                    HistorySheet(viewModel: viewModel)
                }
                .sheet(isPresented: $pattternPopup) {
                    PatternView()
                        .presentationDetents([.height(400)])
                }
        }
    }

    func display(correctKana: String, incorrectKana: String) {
        let correctKana = viewModel.pitchRepersentation(minimalPair: correctKana)
        let incorrectKana = viewModel.pitchMisrepersentation(minimalPair: incorrectKana)
        let correctId = viewModel.getCorrectID()

        if Bool.random() {
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

struct HistorySheet: View {
    let viewModel: PlayerViewModel
    var body: some View {
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
}

struct PitchPatternsView: View {
    let viewModel: PlayerViewModel
    private var numOfCorrect: Int {
        viewModel.answerHistory.filter { $0.isCorrect }.count
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
                .font(.title3)
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .background(.gray.opacity(0.7))
                .clipShape(Capsule())
            Spacer()
            Text("\(numOfCorrect) of \(totalAttempts) (\(percentage))")
                .minimumScaleFactor(0.5)
                .lineLimit(1)

        }
        HStack {
            Text("Heiban")
                .font(.title3)
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .background(.blue.opacity(0.7))
                .clipShape(Capsule())
            Text("Odaka")
                .font(.title3)
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .background(.green.opacity(0.7))
                .clipShape(Capsule())
            Spacer()
            Text("\(correctCount(pitchType:.heiban)) of \(totalCount(pitchType:.heiban)) (\(percentage(pitchType:.heiban)))")
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }

        HStack {
            Text("Atamadaka")
                .font(.title3)
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .background(.red.opacity(0.7))
                .clipShape(Capsule())
            Spacer()
            Text("\(correctCount(pitchType:.atamadaka)) of \(totalCount(pitchType:.atamadaka)) (\(percentage(pitchType:.atamadaka)))")
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        HStack {
            Text("Nakadaka")
                .font(.title3)
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .background(.orange.opacity(0.7))
                .clipShape(Capsule())
            Spacer()
            Text("\(correctCount(pitchType:.nakadaka)) of \(totalCount(pitchType:.nakadaka)) (\(percentage(pitchType:.nakadaka)))")
                .minimumScaleFactor(0.5)
                .lineLimit(1)
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
