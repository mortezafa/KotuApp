// ContentView.swift

import SwiftUI
import AVFoundation


struct ContentView: View {

    var viewModel = PlayerViewModel()
    @State private var titleWord: String = " "
    @State private var leftButtonText: String = " "
    @State private var leftId: UUID = UUID()
    @State private var rightId: UUID = UUID()
    @State private var rightButtonText: String = " "
    @State private var selectedButton: Int? = nil
    @State private var isLeftButtonCorrect: Bool? = nil
    @State private var isRightButtonCorrect: Bool? = nil


    var body: some View {
        VStack {
            HistortyPatternView()
            Spacer()
            Text(titleWord)
                .padding(.bottom, 30)
                .font(.largeTitle)
            Button {
                Task {
                    viewModel.repeatsound()
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
                    let isCorrect = isCorrectWord(currentID: leftId, correctID: viewModel.getCorrectID())
                    isLeftButtonCorrect = isCorrect
                    isRightButtonCorrect = !isCorrect
                } label: {
                    Text(leftButtonText)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(isLeftButtonCorrect == true ? Color("correct") : (isLeftButtonCorrect == false ? Color("inCorrect") : Color.blue))

                Button {
                    let isCorrect = isCorrectWord(currentID: rightId, correctID: viewModel.getCorrectID())
                    isRightButtonCorrect = isCorrect
                    isLeftButtonCorrect = !isCorrect
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
                    await viewModel.playMinimalPair()
                    titleWord = viewModel.fetchCorrectWord()

                    displayCorrectKanaUI(correctKana: viewModel.fetchCorrectWord())

                   isLeftButtonCorrect = nil
                   isRightButtonCorrect = nil
                }
            } label: {
                Text("Continue")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            VStack(alignment: .leading) {
                PitchPatternsView()
            }
            .font(.title2)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .onAppear(perform: {
            Task{
                await viewModel.playMinimalPair()
                titleWord = viewModel.fetchCorrectWord()
                displayCorrectKanaUI(correctKana: viewModel.fetchCorrectWord())
            }
        })
    }
    func displayCorrectKanaUI(correctKana: String) {
        let correctKana = viewModel.pitchRepersentation()
        let incorrectKana = viewModel.pitchMisrepresentation()
        let correctId = viewModel.getCorrectID()
        let randomNumber = Int.random(in: 1...2)
        if randomNumber == 1 {
            leftButtonText = correctKana
            leftId = correctId
            rightId = UUID()
//            correctButton = 1
            rightButtonText = incorrectKana
        } else {
            rightButtonText = correctKana
            rightId = correctId
            leftId = UUID()
//            correctButton = 2
            leftButtonText = incorrectKana
        }
    }


    func isCorrectWord(currentID: UUID, correctID: UUID) -> Bool {
        return currentID == correctID
    }
}

struct HistoryView: View {
    var body: some View {
        VStack {
            List {
                Group {
                    Text("ジョウキョウク")
                    Text("ジョウキョウク")
                    Text("ガッコウ")
                    Text("ガッコウ")
                    Text("ジョウキョウク")
                    Text("ガッコウ")
                    Text("ジョウキョウク")
                    Text("ジョウキョウク")
                    Text("ジョウキョウク")
                    Text("ジョウキョウク")
                }
            }
            .frame(width: .infinity, height: .infinity)
        }
    }
}

struct HistortyPatternView: View {
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
                HistoryView()
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
            Text("0 of 0 (0%)")
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
            Text("0 of 0 (0%)")
        }
        HStack {
            Text("Atamadaka")
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .background(.red.opacity(0.7))
                .clipShape(Capsule())
            Spacer()
            Text("0 of 0 (0%)")
        }
        HStack {
            Text("Nakadaka")
                .padding(.horizontal, 16)
                .padding(.vertical, 3)
                .background(.orange.opacity(0.7))
                .clipShape(Capsule())
            Spacer()
            Text("0 of 0 (0%)")
        }
    }
}

#Preview {
    ContentView()
}
