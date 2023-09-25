// PatternView.swift

import SwiftUI

struct PatternView: View {
    @State var checkedHeibanOdaka = false
    @State var checkedAtamadaka = false
    @State var checkedNakaDaka1 = false
    @State var checkedNakaDaka2 = false
    @State var checkedNakaDaka3 = false


    var body: some View {
        VStack {
            Toggle(isOn: $checkedHeibanOdaka) {
                    Text("Heiban/Odaka: ")
                    Text("◯◯◯◯｜◯◯◯◯")
                    .padding(.all, 0.5)
                }
                .padding()

                Toggle(isOn: $checkedAtamadaka) {
                    Text("Atamadaka: ")
                    Text("◯◯◯◯")
                        .padding(.all, 0.5)
            }
                .padding()

            Text("Nakadaka: \n")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            Toggle(isOn: $checkedNakaDaka1) {
                Text("◯◯〜◯◯")
                    .padding()
                    .fontWeight(.none)
            }
            .padding()
            Toggle(isOn: $checkedNakaDaka2) {
                Text("◯◯〜◯〜◯◯")
                    .fontWeight(.none)
            }
            .padding()
            Toggle(isOn: $checkedNakaDaka3) {
                Text("◯◯〜◯◯")
                    .padding()
                    .fontWeight(.none)
            }
            .padding()

        }
        .font(.title2)
        .fontWeight(.bold)
    }
}

struct PatternView_Previews: PreviewProvider {
    static var previews: some View {
        PatternView()
    }
}
