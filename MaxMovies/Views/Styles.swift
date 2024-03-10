//
//  Styles.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import Foundation
import SwiftUI

struct AppButtonStyle: ViewModifier {
    var buttonColor: Color = .blue
    var foregroundColor: Color = .secondary
    var borderColor: Color = .clear
    var borderWidth: CGFloat = 1
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .frame(minWidth: 44, minHeight: 44)
            .foregroundColor(foregroundColor)
            .font(.subheadline)
            .background(buttonColor)
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(borderColor, lineWidth: borderWidth)
            }
            .shadow(color: buttonColor.opacity(0.2), radius: 4)
    }
}

struct ColorChangingPlaceholderView: View {
    @State private var isHighlighted = false
    let maxHeight: CGFloat
    let aspectRatio: ContentMode
    var animation: Animation {
        Animation.linear(duration: 0.5).repeatForever(autoreverses: true)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black.opacity(isHighlighted ? 0.3 : 0.1))
            .frame(maxHeight: maxHeight)
            .aspectRatio(contentMode: aspectRatio)
            .onAppear {
                withAnimation(animation) {
                    isHighlighted.toggle()
                }
            }
    }
}
