import SwiftUI

struct AppTheme {
    static let background = Color(red: 14/255, green: 22/255, blue: 30/255)
    static let teal = Color(red: 78/255, green: 194/255, blue: 191/255)
    static let purple = Color(red: 150/255, green: 140/255, blue: 215/255)
    static let text = Color.white

    static func primaryButtonStyle() -> some ButtonStyle {
        PlainButtonStyle()
    }
}

extension View {
    func centeredFill() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(AppTheme.background)
    }

    func primaryButton() -> some View {
        padding()
            .frame(maxWidth: .infinity)
            .background(AppTheme.teal.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundColor(AppTheme.text)
            .font(.headline)
    }

    func mutedText() -> some View {
        foregroundColor(AppTheme.text.opacity(0.7))
    }
}
