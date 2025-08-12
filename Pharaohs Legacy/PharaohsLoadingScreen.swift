import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct PharaohsLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var pulse = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Фон: logo + затемнение
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.45))

                VStack {
                    Spacer()
                    // Пульсирующий логотип
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.38)
                        .scaleEffect(pulse ? 1.02 : 0.82)
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                        .animation(
                            Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                            value: pulse
                        )
                        .onAppear { pulse = true }
                        .padding(.bottom, 36)
                    // Прогрессбар и проценты
                    VStack(spacing: 14) {
                        Text("Loading \(progressPercentage)%")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        PharaohsProgressBar(value: progress)
                            .frame(width: geo.size.width * 0.52, height: 10)
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.22))
                    .cornerRadius(14)
                    .padding(.bottom, geo.size.height * 0.18)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Фоновые представления

struct PharaohsBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct PharaohsProgressBar: View {
    let value: Double
    @State private var shimmerOffset: CGFloat = -1
    @State private var pulseScale: CGFloat = 1.0
    @State private var gemGlow: Double = 0.5

    var body: some View {
        GeometryReader { geometry in
            progressContainer(in: geometry)
                .onAppear {
                    startAnimations()
                }
        }
    }

    private func progressContainer(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            backgroundTrack(height: geometry.size.height)
            progressTrack(in: geometry)
            egyptianDecorations(in: geometry)
        }
    }

    private func backgroundTrack(height: CGFloat) -> some View {
        ZStack {
            // Основной фон с египетской текстурой
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#1A1611"), Color(hex: "#2D2418"), Color(hex: "#1A1611"),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    // Египетский узор
                    RoundedRectangle(cornerRadius: height / 2)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#8B7355").opacity(0.6),
                                    Color(hex: "#D4AF37").opacity(0.3),
                                    Color(hex: "#8B7355").opacity(0.6),
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.black.opacity(0.4), radius: 4, y: 2)
                .shadow(color: Color(hex: "#8B7355").opacity(0.2), radius: 2, y: -1)
        }
        .frame(height: height)
    }

    private func progressTrack(in geometry: GeometryProxy) -> some View {
        let width = CGFloat(value) * geometry.size.width
        let height = geometry.size.height

        return ZStack(alignment: .leading) {
            // Основной золотой прогресс
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#FFD700"),
                            Color(hex: "#FFA500"),
                            Color(hex: "#FF8C00"),
                            Color(hex: "#FFD700"),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .scaleEffect(y: pulseScale)
                .shadow(color: Color(hex: "#FFD700").opacity(0.6), radius: 8, y: 0)
                .shadow(color: Color.orange.opacity(0.4), radius: 4, y: 2)

            // Анимированный блик
            if width > 0 {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.7),
                                Color.clear,
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width * 0.3, height: height * 0.8)
                    .offset(x: width * shimmerOffset)
                    .clipped()
            }

            // Внутренний блик
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#FFFACD").opacity(0.8),
                            Color.clear,
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width, height: height * 0.4)
                .offset(y: -height * 0.15)
        }
        .clipShape(RoundedRectangle(cornerRadius: height / 2))
        .animation(.easeInOut(duration: 0.3), value: value)
    }

    private func egyptianDecorations(in geometry: GeometryProxy) -> some View {
        let height = geometry.size.height
        let width = geometry.size.width

        return ZStack {
            // Египетские символы по краям
            HStack {
                egyptianSymbol("◆", size: height * 0.6)
                    .foregroundColor(Color(hex: "#D4AF37").opacity(0.8))
                Spacer()
                egyptianSymbol("◆", size: height * 0.6)
                    .foregroundColor(Color(hex: "#D4AF37").opacity(0.8))
            }
            .frame(width: width + height)

            // Драгоценные камни на прогрессе
            if value > 0.1 {
                HStack(spacing: width * 0.15) {
                    ForEach(0..<Int(value * 5), id: \.self) { _ in
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#00CED1").opacity(gemGlow),
                                        Color(hex: "#008B8B").opacity(gemGlow * 0.8),
                                        Color.clear,
                                    ]),
                                    center: .center,
                                    startRadius: 1,
                                    endRadius: height * 0.15
                                )
                            )
                            .frame(width: height * 0.2, height: height * 0.2)
                            .scaleEffect(gemGlow)
                    }
                }
                .frame(width: CGFloat(value) * width, alignment: .leading)
                .clipped()
            }
        }
    }

    private func egyptianSymbol(_ symbol: String, size: CGFloat) -> some View {
        Text(symbol)
            .font(.system(size: size, weight: .bold))
            .shadow(color: Color(hex: "#FFD700").opacity(0.5), radius: 2, y: 0)
    }

    private func startAnimations() {
        // Анимация блика
        withAnimation(
            Animation.linear(duration: 2.0)
                .repeatForever(autoreverses: false)
        ) {
            shimmerOffset = 1.5
        }

        // Пульсация прогресса
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.05
        }

        // Мерцание драгоценных камней
        withAnimation(
            Animation.easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        ) {
            gemGlow = 1.0
        }
    }
}

// MARK: - Превью

#Preview("Vertical") {
    PharaohsLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    PharaohsLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}
