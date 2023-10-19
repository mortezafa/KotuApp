// ContentView.swift

import SwiftUI
import AVFoundation


struct ContentView: View {
    @State var historyPopup = false
    @State var howtoPopup = false
    @State var pattternPopup = false
    @StateObject private var viewModel = PlayerViewModel()

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


    var body: some View {
        VStack {
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
                        .presentationDetents([.height(350)])
                }
            }
            Spacer()
            Text("こうりゃく")
                .font(.title)
            Button {
                Task {
                    await viewModel.playMinimalPair()
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

            HStack() {
                Button {

                } label: {
                    Text("コーリャク")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                Button {

                } label: {
                    Text("コ＼ーリャク")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
            }

            Divider()
                .padding(.vertical)

            Button {

            } label: {
                Text("Continue")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            VStack(alignment: .leading) {
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
            .font(.title2)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
