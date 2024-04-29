import SwiftUI

struct HowtoView :View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
    VStack {
        Button {
            dismiss()
        } label: {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 30, alignment: .trailing)
                    .padding(.trailing, 40)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            }
        Spacer()
        Text("Minimal Pairs")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(.black)
            .padding()
        Text("\u{2022} This test uses the symbol \u{FF3C}  after the accented mora in a word to indicate a pitch drop. For example, たか\u{FF3C}い is pronounced low-high-low, and まちが\u{FF3C}い is pronounced low-high-high-low. If the word is flat (heiban), there is no \u{FF3C}, such as in: くるま low-high-high. Rises in pitch are not notated in any words.")
            .padding(.all, 20)
            .font(.callout)
        Text("\u{2022} All audio, and all potential answers on this test are real words. But the purpose of the test is not to think of words (because that would be testing recall), but rather to test your pitch accent perception by simply choosing the correct notation based on how the recording sounds.")
            .padding(.all, 15)
            .font(.callout)

        Text("\u{2022} There is a slight falling contour at the end of heiban words in this test because the words are said in isolation. It is important to be able to distinguish that slight falling contour from an actual accent, and that will be something you become able to do as you get used to the test.")
            .padding(.all, 15)
            .font(.callout)
        Spacer()
        HStack {
            Text("This text was taken from")
                .italic()
            Link("kotu.io", destination: URL(string: "https://kotu.io/")!)
                .italic()
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HowtoView()
    }
}
