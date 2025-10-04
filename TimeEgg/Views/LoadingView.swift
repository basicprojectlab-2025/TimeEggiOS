//
//  LoadingView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/4/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("TimeEgg")
              .font(
                Font.custom("Edu AU VIC WA NT Hand", size: 50)
                  .weight(.bold)
              )
              .multilineTextAlignment(.center)
              .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
              .frame(width: 260, alignment: .top)
        }
        .padding(.leading, 21)
        .padding(.trailing, 20)
        .padding(.top, 156)
        .padding(.bottom, 235)
        .frame(width: 375, alignment: .top)
        .background(Color(red: 0.97, green: 0.98, blue: 1))
            
        
    }
}

#Preview {
    LoadingView()
}
