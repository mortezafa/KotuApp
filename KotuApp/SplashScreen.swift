// SplashScreen.swift

import SwiftUI

struct SplashScreen: View {
    @State var isActive:Bool = false
    @State private var size = 0.8
    @State private var opacity = 0.5


    var body: some View {

        if isActive {
            ContentView()
        } else {
            ZStack{
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea()

                VStack{
                    Text("コツ")
                        .foregroundStyle(.black)
                        .font(.system(size: 100))

                    Text("Kotu")
                        .foregroundStyle(.black)
                        .font(.largeTitle)
                        .bold()
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
