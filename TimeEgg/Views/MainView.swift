//
//  MainView.swift
//  TimeEgg
//
//  Created by donghyeon choi on 10/4/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack() {
            Group {
                Text("차차님, 안녕하세요 (예시)")
                    .font(Font.custom("DM Sans", size: 28).weight(.bold))
                    .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .offset(x: -3, y: -264)
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 40, height: 40)
                    .background(.white)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .inset(by: 0.50)
                            .stroke(
                                Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.40), lineWidth: 0.50
                            )
                    )
                    .offset(x: 147.50, y: -352)
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 974, height: 4096)
                    .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                    .offset(x: 1475.50, y: 770)
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 18, height: 23)
                    .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                    .offset(x: 147.50, y: -352.50)
                    .shadow(
                        color: Color(red: 0.59, green: 0.43, blue: 0.34, opacity: 0.20), radius: 15, y: 8
                    )
                ZStack() {
                    ZStack() {
                        Ellipse()
                            .foregroundColor(.clear)
                            .frame(width: 60, height: 60)
                            .background(Color(red: 0.98, green: 0.53, blue: 0.12))
                            .offset(x: 0, y: 0)
                            .shadow(
                                color: Color(red: 0.59, green: 0.43, blue: 0.34, opacity: 0.20), radius: 15, y: 8
                            )
                    }
                    .frame(width: 60, height: 60)
                    .offset(x: -1, y: -17.50)
                    ZStack() {
                        
                    }
                    .foregroundColor(.clear)
                    .frame(width: 24, height: 24)
                    .offset(x: -137, y: -1.50)
                    ZStack() {
                        HStack(spacing: 10) {
                            
                        }
                        .padding(2)
                        .frame(width: 24, height: 24)
                        .background(.white)
                        .offset(x: 0, y: 0)
                    }
                    .frame(width: 24, height: 24)
                    .offset(x: -137, y: 0.50)
                    ZStack() {
                        HStack(spacing: 10) {
                            
                        }
                        .padding(2)
                        .frame(width: 24, height: 24)
                        .background(.white)
                        .offset(x: 0, y: 0)
                    }
                    .frame(width: 24, height: 24)
                    .offset(x: -70, y: 0.50)
                    ZStack() {
                        HStack(spacing: 10) {
                            
                        }
                        .padding(3)
                        .frame(width: 24, height: 24)
                        .background(.white)
                        .offset(x: 0, y: 0)
                    }
                    .frame(width: 24, height: 24)
                    .offset(x: 65, y: 0.50)
                    ZStack() {
                        HStack(spacing: 10) {
                            
                        }
                        .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                        .frame(width: 24, height: 24)
                        .background(.white)
                        .offset(x: 0, y: 0)
                    }
                    .frame(width: 24, height: 24)
                    .offset(x: 130, y: 0.50)
                }
                .frame(width: 378, height: 115)
                .offset(x: 0.50, y: 348.50)
                ZStack() {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 375, height: 44)
                        .offset(x: 0, y: 0)
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 22, height: 11.33)
                        .cornerRadius(2.67)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2.67)
                                .inset(by: 0.50)
                                .stroke(.black, lineWidth: 0.50)
                        )
                        .offset(x: 159.50, y: 0.99)
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 18, height: 7.33)
                        .background(.black)
                        .cornerRadius(1.33)
                        .offset(x: 159.50, y: 0.99)
                    ZStack() {
                        Text("9:41")
                            .font(Font.custom("SF Pro Text", size: 14).weight(.semibold))
                            .foregroundColor(.black)
                            .offset(x: 0, y: 1)
                    }
                    .frame(width: 54, height: 21)
                    .offset(x: -139.50, y: 1.50)
                }
                .frame(width: 375, height: 44)
                .offset(x: 0, y: -386)
                Text("나의 캡슐")
                    .font(Font.custom("DM Sans", size: 16).weight(.bold))
                    .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .offset(x: -136, y: 19.50)
                ZStack() {
                    Text("view all(29)")
                        .font(Font.custom("Inter", size: 14))
                        .lineSpacing(21.32)
                        .underline()
                        .foregroundColor(Color(red: 1, green: 0.33, blue: 0.29))
                        .offset(x: 0, y: 0)
                }
                .frame(width: 75, height: 21)
                .offset(x: 127, y: 19.50)
                HStack(alignment: .top, spacing: 20) {
                    ZStack() {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 185, height: 220)
                            .background(.white)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .inset(by: 0.50)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                            )
                            .offset(x: 0, y: 0)
                        Text("캡슐제목2")
                            .font(Font.custom("Inter", size: 15))
                            .lineSpacing(22)
                            .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.25))
                            .offset(x: -1, y: 51)
                        Text("2025.09.12 ")
                            .font(Font.custom("Inter", size: 10))
                            .lineSpacing(22)
                            .foregroundColor(Color(red: 0.36, green: 0.39, blue: 0.47))
                            .offset(x: -0.50, y: 67)
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 116, height: 21)
                                .background(Color(red: 0.98, green: 0.74, blue: 0.02).opacity(0.60))
                                .cornerRadius(30)
                                .offset(x: 0, y: -0.50)
                            Text("D-12")
                                .font(Font.custom("Inter", size: 12))
                                .lineSpacing(22)
                                .foregroundColor(.black)
                                .offset(x: -1, y: 0)
                        }
                        .frame(width: 116, height: 22)
                        .offset(x: 0.50, y: 89)
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 150, height: 150)
                            .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                            .offset(x: -0.50, y: -35)
                    }
                    .frame(width: 185, height: 220)
                    ZStack() {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 185, height: 220)
                            .background(.white)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .inset(by: 0.50)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                            )
                            .offset(x: 0, y: 0)
                        Text("캡슐제목1")
                            .font(Font.custom("Inter", size: 15))
                            .lineSpacing(22)
                            .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.25))
                            .offset(x: -1, y: 51)
                        Text("2025.09.12 ")
                            .font(Font.custom("Inter", size: 10))
                            .lineSpacing(22)
                            .foregroundColor(Color(red: 0.36, green: 0.39, blue: 0.47))
                            .offset(x: -0.50, y: 67)
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 116, height: 21)
                                .background(Color(red: 0.98, green: 0.74, blue: 0.02).opacity(0.60))
                                .cornerRadius(30)
                                .offset(x: 0, y: -0.50)
                            Text("D-12")
                                .font(Font.custom("Inter", size: 12))
                                .lineSpacing(22)
                                .foregroundColor(.black)
                                .offset(x: -1, y: 0)
                        }
                        .frame(width: 116, height: 22)
                        .offset(x: 0.50, y: 89)
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 150, height: 150)
                            .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                            .offset(x: 0.50, y: -35)
                    }
                    .frame(width: 185, height: 220)
                    ZStack() {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 185, height: 220)
                            .background(.white)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .inset(by: 0.50)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                            )
                            .offset(x: 0, y: 0)
                        Text("캡슐제목3")
                            .font(Font.custom("Inter", size: 15))
                            .lineSpacing(22)
                            .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.25))
                            .offset(x: -1.50, y: 51)
                        Text("2025.09.12 ")
                            .font(Font.custom("Inter", size: 10))
                            .lineSpacing(22)
                            .foregroundColor(Color(red: 0.36, green: 0.39, blue: 0.47))
                            .offset(x: -0.50, y: 67)
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 116, height: 21)
                                .background(Color(red: 0.98, green: 0.74, blue: 0.02).opacity(0.60))
                                .cornerRadius(30)
                                .offset(x: 0, y: -0.50)
                            Text("D-12")
                                .font(Font.custom("Inter", size: 12))
                                .lineSpacing(22)
                                .foregroundColor(.black)
                                .offset(x: -1, y: 0)
                        }
                        .frame(width: 116, height: 22)
                        .offset(x: 0.50, y: 89)
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 150, height: 150)
                            .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                            .offset(x: -0.50, y: -35)
                    }
                    .frame(width: 185, height: 220)
                    ZStack() {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 185, height: 220)
                            .background(.white)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .inset(by: 0.50)
                                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 0.50)
                            )
                            .offset(x: 0, y: 0)
                        Text("캡슐제목4")
                            .font(Font.custom("Inter", size: 15))
                            .lineSpacing(22)
                            .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.25))
                            .offset(x: -1.50, y: 51)
                        Text("2025.09.12 ")
                            .font(Font.custom("Inter", size: 10))
                            .lineSpacing(22)
                            .foregroundColor(Color(red: 0.36, green: 0.39, blue: 0.47))
                            .offset(x: -0.50, y: 67)
                        ZStack() {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 116, height: 21)
                                .background(Color(red: 0.98, green: 0.74, blue: 0.02).opacity(0.60))
                                .cornerRadius(30)
                                .offset(x: 0, y: -0.50)
                            Text("D-12")
                                .font(Font.custom("Inter", size: 12))
                                .lineSpacing(22)
                                .foregroundColor(.black)
                                .offset(x: -1, y: 0)
                        }
                        .frame(width: 116, height: 22)
                        .offset(x: 0.50, y: 89)
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 150, height: 150)
                            .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                            .offset(x: -1.50, y: -35)
                    }
                    .frame(width: 185, height: 220)
                }
                .frame(width: 334)
                .offset(x: -0.50, y: 173)
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 327, height: 188)
                    .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                    .cornerRadius(20)
                    .offset(x: 0, y: -139)
                    .blur(radius: 0.50)
            }
            Group {
                Ellipse()
                    .foregroundColor(.clear)
                    .frame(width: 30, height: 30)
                    .background(Color(red: 0.93, green: 0.27, blue: 0.27))
                    .offset(x: -23.50, y: -121)
                Ellipse()
                    .foregroundColor(.clear)
                    .frame(width: 30, height: 30)
                    .background(Color(red: 0.93, green: 0.41, blue: 0.27))
                    .offset(x: 105.50, y: -139)
                Ellipse()
                    .foregroundColor(.clear)
                    .frame(width: 30, height: 30)
                    .background(Color(red: 0.97, green: 0.52, blue: 0.52))
                    .offset(x: -83.50, y: -180)
                Text("+5")
                    .font(Font.custom("Inter", size: 14).weight(.black))
                    .foregroundColor(.black)
                    .offset(x: -24.50, y: -120.50)
                Text("+2")
                    .font(Font.custom("Inter", size: 14).weight(.black))
                    .foregroundColor(.black)
                    .offset(x: -84, y: -179.50)
                Text("+1")
                    .font(Font.custom("Inter", size: 14).weight(.black))
                    .foregroundColor(.black)
                    .offset(x: 105, y: -138.50)
                Text("TimeEgg")
                    .font(Font.custom("Edu AU VIC WA NT Hand", size: 30).weight(.bold))
                    .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                    .offset(x: -0.50, y: -350)
            }
        }
        .frame(width: 375, height: 812)
        .background(Color(red: 0.97, green: 0.98, blue: 1))
    }
}

#Preview {
    MainView()
}
