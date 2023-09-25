// ContentView.swift

import SwiftUI



struct ContentView: View {
    @State var historyPopup = false
    @State var howtoPopup = false
    @State var pattternPopup = false

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
            Spacer()
            HStack {
                Button {
                    howtoPopup.toggle()
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                }
                .font(.largeTitle)
                .fullScreenCover(isPresented: $howtoPopup, content: HowtoView.init)
            }
            .offset(x: 150, y: -170)
            HStack {
                Button {
                    historyPopup.toggle()
                } label: {
                    Text("History")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)

                }
                .buttonStyle(.bordered)
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
                .buttonStyle(.bordered)
                .sheet(isPresented: $pattternPopup) {
                    PatternView()
                        .presentationDetents([.large])
                }
            }
            .offset(x:0, y:-150)

            .frame(alignment: .topLeading)
            Text("こうりゃく")
                .font(.title)
            Button {

            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            .padding(10)
            .background(Color(white: 0.75))
            .clipShape(Capsule())

            Rectangle()
                .frame(height: 3)
                .foregroundStyle(Color(white: 0.75))
                .padding(10)

            HStack() {
                Button {

                } label: {
                    Text("コーリャク")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                Button {

                } label: {
                    Text("コ＼ーリャク")
                        .font(.title)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
            }

            Rectangle()
                .frame(height: 3)
                .foregroundStyle(Color(white: 0.75))
                .padding(10)

            Button {

            } label: {
                Text("Continue")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            VStack(alignment: .leading) {
                Text("**All:** 0 of 0 (0%)\n")
                    .frame(maxWidth: .infinity)
                Text("**Heiban / Odaka:** 0 of 0 (0%)\n")
                Text("**Atamadaka:** 0 of 0 (0%)\n")
                Text("**Nakadaka:** 0 of 0 (0%)\n")
            }
            .font(.title)
            .offset(y: 25)
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
