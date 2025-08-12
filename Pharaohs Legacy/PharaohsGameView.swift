import Foundation
import SwiftUI

struct PharaohsEntryScreen: View {
    @StateObject private var loader: PharaohsWebLoader

    init(loader: PharaohsWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            PharaohsWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                PharaohsProgressIndicator(value: percent)
            case .failure(let err):
                PharaohsErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                PharaohsOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct PharaohsProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            PharaohsLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct PharaohsErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct PharaohsOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
