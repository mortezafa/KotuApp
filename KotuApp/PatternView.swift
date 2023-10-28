// PatternView.swift

import SwiftUI

struct PatternView: View {
    @State var checkedHeibanOdaka = false
    @State var checkedAtamadaka = false
    @State var checkedNakaDaka1 = false
    @State var checkedNakaDaka2 = false
    @State var checkedNakaDaka3 = false


    var body: some View {
        VStack(alignment: .leading) {
            Text("Patterns")
                .font(.largeTitle)
                .padding(.vertical)
            Text("Heiban / Odaka")
            Toggle(isOn: $checkedHeibanOdaka) {
                HStack(spacing: 0) {
                    Text("◯")
                    Text("◯◯◯")
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(.red)
                                .frame(height: 1)
                                .padding(.vertical, -0.5)

                        }
                    Text(" | ◯")
                    Text("◯◯◯")
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(.red)
                                .frame(height: 1)
                                .padding(.vertical, -3)
                            Rectangle()
                                .fill(.red)
                                .frame(width: 1, height: 5)
                                .frame(maxWidth: .infinity, alignment: .trailing)

                        }
                }
                    .fontWeight(.none)
            }

            Text("Atamadaka")
            Toggle(isOn: $checkedAtamadaka) {
                HStack (spacing: 0) {
                    Text("◯")
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(.red)
                                .frame(height: 1)
                                .padding(.vertical, -3)
                            Rectangle()
                                .fill(.red)
                                .frame(width: 1, height: 5)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    Text("◯◯◯")
                }
                .fontWeight(.none)
            }

            Text("Nakadaka")
                .frame(maxWidth: .infinity, alignment: .leading)

            Toggle(isOn: $checkedNakaDaka1) {
                HStack(spacing: 0) {
                    Text("◯")
                    Text("◯")
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(.red)
                                .frame(height: 1)
                                .padding(.vertical, -3)
                            Rectangle()
                                .fill(.red)
                                .frame(width: 1, height: 5)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    Text("〜◯◯")
                }
                .fontWeight(.none)
            }
            Toggle(isOn: $checkedNakaDaka2) {
                HStack(spacing: 0) {
                    Text("◯")
                    Text("◯〜◯")
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(.red)
                                .frame(height: 1)
                                .padding(.vertical, -3)
                            Rectangle()
                                .fill(.red)
                                .frame(width: 1, height: 5)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    Text("〜◯◯")
                }
                .fontWeight(.none)
            }
            Toggle(isOn: $checkedNakaDaka3) {
                HStack(spacing: 0) {
                    Text("◯")
                    Text("◯〜◯")
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(.red)
                                .frame(height: 1)
                                .padding(.vertical, -3)
                            Rectangle()
                                .fill(.red)
                                .frame(width: 1, height: 5)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    Text("◯")
                }
                    .fontWeight(.none)
            }
        }
        .font(.title2)
        .fontWeight(.bold)
        .padding(.horizontal)
    }
}

struct PatternView_Previews: PreviewProvider {
    static var previews: some View {
        PatternView()
    }
}
