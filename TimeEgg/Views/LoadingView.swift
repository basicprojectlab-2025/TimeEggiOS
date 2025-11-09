//
//  LoadingView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/4/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경
                Color(red: 0.97, green: 0.98, blue: 1)
                    .ignoresSafeArea()
                
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    
                    Text("TimeEgg")
                        .font(Font.custom("Edu AU VIC WA NT Hand", size: geometry.size.width * 0.13).weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .frame(maxWidth: geometry.size.width * 0.7)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    LoadingView()
}
