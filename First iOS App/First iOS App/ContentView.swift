import SwiftUI
import AVKit
import SafariServices
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var videoURL: String = ""
    @State private var videoFileURL: URL?
    @State private var audioFileURL: URL?
    @State private var isMenuOpen = false
    @State private var showWebView = false
    @State private var urlToOpen: String?
    @State private var player: AVPlayer?

    @State private var isPickingVideo = false
    @State private var isPickingAudio = false

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("🎬 SimpliPlay")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)

                        // Video URL Control
                        VStack(spacing: 10) {
                            TextField("Enter Media URL", text: $videoURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)

                            HStack {
                                Button("Play Media") {
                                    playVideo(urlString: videoURL)
                                }
                                .buttonStyle(PrimaryButtonStyle())

                                Button("Clear") {
                                    videoURL = ""
                                }
                                .foregroundColor(.red)
                            }
                        }

                        // File Picker Section
                        VStack(spacing: 12) {
                            HStack {
                                Button("Choose Video File", action: { isPickingVideo = true })
                                Button("Choose Audio File", action: { isPickingAudio = true })
                            }

                            if let video = videoFileURL {
                                Text("🎞️ \(video.lastPathComponent)")
                                Button("Play Selected Video") {
                                    playLocalVideo(fileURL: video)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }

                            if let audio = audioFileURL {
                                Text("🎵 \(audio.lastPathComponent)")
                            }
                        }
                        .padding(.horizontal)

                        Button("Open Menu") {
                            isMenuOpen.toggle()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding()
                }

                if isMenuOpen {
                    VStack(alignment: .leading, spacing: 20) {
                        Button("Official Website") {
                            urlToOpen = "https://simpliplay.netlify.app"
                            showWebView = true
                            isMenuOpen = false
                        }
                        
                        Button("About the Creator") {
                            urlToOpen = "https://a-star100.github.io"
                            showWebView = true
                            isMenuOpen = false
                        }
                        

                        Button("Close Menu") {
                            isMenuOpen = false
                        }
                    }
                    .padding()
                    .frame(maxWidth: 250, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                    .transition(.move(edge: .leading))
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showWebView) {
                if let urlString = urlToOpen, let url = URL(string: urlString) {
                    SafariView(url: url)
                }
            }
            .sheet(isPresented: $isPickingVideo) {
                DocumentPicker(fileType: .movie) { url in
                    videoFileURL = url
                }
            }
            .sheet(isPresented: $isPickingAudio) {
                DocumentPicker(fileType: .audio) { url in
                    audioFileURL = url
                }
            }
        }
    }

    // MARK: - Video Playback Helpers

    func playVideo(urlString: String) {
        if let url = URL(string: urlString) {
            player = AVPlayer(url: url)
            let controller = AVPlayerViewController()
            controller.player = player
            controller.modalPresentationStyle = .fullScreen
            present(controller)
        }
    }

    func playLocalVideo(fileURL: URL) {
        player = AVPlayer(url: fileURL)
        let controller = AVPlayerViewController()
        controller.player = player
        controller.modalPresentationStyle = .fullScreen
        present(controller)
        player?.play()
    }

    func present(_ viewController: UIViewController) {
        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController }).first {
            rootVC.present(viewController, animated: true)
        }
    }
}

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.blue.opacity(0.6) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
    }
}

// MARK: - Safari View

struct SafariView: View {
    var url: URL
    var body: some View {
        SafariViewController(url: url)
            .edgesIgnoringSafeArea(.all)
    }
}

struct SafariViewController: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    var fileType: UTType
    var onPick: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [fileType], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                onPick(url)
            }
        }
    }
}

