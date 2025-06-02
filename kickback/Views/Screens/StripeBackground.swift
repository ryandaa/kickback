import SwiftUI

struct StripeBackground: View {
    let colors: [Color] = [
        Color(hex: "#F5F7F2"), // milky white
        Color(hex: "#E3E7DF"), // greenish white
        Color(hex: "#7B8C6A"), // olive green
        Color(hex: "#A3B18A")  // sage green
    ]
    let stripeWidth: CGFloat = 80
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<Int(geo.size.width / stripeWidth) + 4, id: \ .self) { i in
                    Rectangle()
                        .fill(colors[i % colors.count])
                        .frame(width: stripeWidth * 1.5, height: geo.size.height * 2)
                        .rotationEffect(.degrees(-30))
                        .offset(x: CGFloat(i) * stripeWidth - geo.size.height / 2)
                }
            }
        }
    }
} 