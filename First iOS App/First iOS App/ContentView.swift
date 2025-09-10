import SwiftUI
import AVKit
import UniformTypeIdentifiers

#if targetEnvironment(macCatalyst)
import AppKit
#else
import SafariServices
#endif

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
    @StateObject private var observer = PlayerObserver()

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("🎬 SimpliPlay")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)

                        VStack(spacing: 10) {
                            TextField("Enter Media URL", text: $videoURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)

                            HStack {
                                Button("Play Media") { playVideo(urlString: videoURL) }
                                    .buttonStyle(PrimaryButtonStyle())
                                Button("Clear") { videoURL = "" }
                                    .foregroundColor(.red)
                            }
                        }

                        VStack(spacing: 12) {
                            HStack {
                                Button("Choose Video File") { pickVideoFile() }
                                Button("Choose Audio File") { pickAudioFile() }
                            }

                            if let video = videoFileURL {
                                Text("🎞️ \(video.lastPathComponent)")
                                Button("Play Selected Video") { playLocalVideo(fileURL: video) }
                                    .buttonStyle(PrimaryButtonStyle())
                            }

                            if let audio = audioFileURL {
                                Text("🎵 \(audio.lastPathComponent)")
                            }
                        }
                        .padding(.horizontal)

                        Button("Open Menu") { isMenuOpen.toggle() }
                            .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding()
                }

                if isMenuOpen {
                    VStack(alignment: .leading, spacing: 20) {
                        Button("Official Website") { openURL("https://simpliplay.netlify.app") }
                        Button("About the Creator") { openURL("https://anirudhsevugan.me") }
                        Button("Close Menu") { isMenuOpen = false }
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
        }
    }

    // MARK: - Playback
    func playVideo(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let newPlayer = AVPlayer(url: url)
        observer.attach(to: newPlayer)
        player = newPlayer
        presentPlayer()
    }

    func playLocalVideo(fileURL: URL) {
        let newPlayer = AVPlayer(url: fileURL)
        observer.attach(to: newPlayer)
        player = newPlayer
        presentPlayer()
    }

    func presentPlayer() {
        guard let player = player else { return }
#if targetEnvironment(macCatalyst)
        let controller = AVPlayerViewController()
        controller.player = player
        controller.view.frame = NSScreen.main?.frame ?? .zero
        let window = NSWindow(contentViewController: controller)
        let windowController = NSWindowController(window: window)
        windowController.showWindow(nil)
#else
        let controller = AVPlayerViewController()
        controller.player = player
        controller.modalPresentationStyle = .fullScreen
        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController }).first {
            rootVC.present(controller, animated: true)
        }
#endif
        player.play()
    }

    // MARK: - File Picking
    func pickVideoFile() {
#if targetEnvironment(macCatalyst)
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK {
            videoFileURL = panel.url
        }
#else
        isPickingVideo = true
#endif
    }

    func pickAudioFile() {
#if targetEnvironment(macCatalyst)
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.audio]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK {
            audioFileURL = panel.url
        }
#else
        isPickingAudio = true
#endif
    }

    // MARK: - Open URL
    func openURL(_ urlString: String) {
#if targetEnvironment(macCatalyst)
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
#else
        urlToOpen = urlString
        showWebView = true
#endif
    }
}

// MARK: - Observer
class PlayerObserver: NSObject, ObservableObject {
    private var observation: NSKeyValueObservation?
    private var player: AVPlayer?

    func attach(to newPlayer: AVPlayer) {
        self.player = newPlayer
        observation?.invalidate()

        observation = newPlayer.observe(\.timeControlStatus, options: [.initial, .new]) { player, _ in
            DispatchQueue.main.async {
#if !targetEnvironment(macCatalyst)
                UIApplication.shared.isIdleTimerDisabled = player.timeControlStatus == .playing
#endif
            }
        }

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: newPlayer.currentItem, queue: .main) { _ in
#if !targetEnvironment(macCatalyst)
            UIApplication.shared.isIdleTimerDisabled = false
#endif
        }
    }

    deinit {
        observation?.invalidate()
#if !targetEnvironment(macCatalyst)
        UIApplication.shared.isIdleTimerDisabled = false
#endif
    }
}

// MARK: - Button Style
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

