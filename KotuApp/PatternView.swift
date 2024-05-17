// PatternView.swift

import SwiftUI

struct PatternView: View {
    @State var kotuService = KotuService.shared

    var body: some View {
        VStack(alignment: .leading) {
            Text("Patterns")
                .font(.largeTitle)
                .padding(.vertical)
            Text("Heiban / Odaka")
            Toggle(isOn: $kotuService.checkedHeibanOdaka) {
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
            .onChange(of: kotuService.checkedHeibanOdaka) {
                Task {
                    try await kotuService.randomMinimalPairs()
                }
            }


            Text("Atamadaka")
            Toggle(isOn: $kotuService.checkedAtamadaka) {
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
            .onChange(of: kotuService.checkedAtamadaka) {
                Task {
                    try await kotuService.randomMinimalPairs()
                }
            }

            Text("Nakadaka")
                .frame(maxWidth: .infinity, alignment: .leading)

            Toggle(isOn: $kotuService.checkedNakaDaka1) {
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
            .onChange(of: kotuService.checkedNakaDaka1) {
                Task {
                    try await kotuService.randomMinimalPairs()
                }
            }

            Toggle(isOn: $kotuService.checkedNakaDaka2) {
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
            .onChange(of: kotuService.checkedNakaDaka2) {
                Task {
                    try await kotuService.randomMinimalPairs()
                }
            }

            Toggle(isOn: $kotuService.checkedNakaDaka3) {
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
            .onChange(of: kotuService.checkedNakaDaka3) {
                Task {
                    try await kotuService.randomMinimalPairs()
                }
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
