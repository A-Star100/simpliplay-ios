import SwiftUI
import AVKit
import SafariServices

struct ContentView: View {
    @State var videoURL: String = ""
    @State var videoFileURL: URL?
    @State var audioFileURL: URL?
    @State private var isMenuOpen = false
    @State private var showWebView = false
    @State private var urlToOpen: String?
    @State private var player: AVPlayer?
    @State private var playerObserver: Any?

    @State private var playlist: [String] = []  // Playlist array
    @State private var currentVideoIndex: Int = 0  // Track the current video in the playlist

    let playlistKey = "playlistKey"  // UserDefaults key
    
    // Load playlist from UserDefaults
    init() {
        if let savedPlaylist = UserDefaults.standard.array(forKey: playlistKey) as? [String] {
            self._playlist = State(initialValue: savedPlaylist)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Video URL input
                    TextField("Enter Video URL", text: $videoURL)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 300)

                    Button("Play Video") {
                        playVideo(urlString: videoURL)
                    }
                    .padding()
                    .frame(width: 300)

                    // File Picker Buttons
                    HStack {
                        Button("Choose Video File") {
                            pickFile(type: .movie)
                        }
                        .padding()
                        
                        Button("Choose Audio File") {
                            pickFile(type: .audio)
                        }
                        .padding()
                    }

                    // Display selected files
                    if let videoURL = videoFileURL {
                        Text("Video Selected: \(videoURL.lastPathComponent)")
                            .padding()
                    }

                    if let audioURL = audioFileURL {
                        Text("Audio Selected: \(audioURL.lastPathComponent)")
                            .padding()
                    }

                    // Side menu button
                    Button("Open Menu") {
                        isMenuOpen.toggle()
                    }
                    .padding()

                    Spacer()
                    
                    // Playlist Button
                    NavigationLink(destination: PlaylistView(playlist: $playlist, onLoad: loadPlaylist, onAdd: addToPlaylist)) {
                        Text("Manage Playlist")
                            .padding()
                            .frame(width: 300)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button("Play Playlist") {
                        playPlaylist()
                    }
                    .padding()
                    .frame(width: 300)
                }

                // Side menu overlay
                if isMenuOpen {
                    VStack {
                        Button("About the Creator") {
                            urlToOpen = "https://a-star100.github.io"
                            showWebView.toggle()
                        }
                        .padding()
                        
                        Button("Close Menu") {
                            isMenuOpen.toggle()
                        }
                        .padding()
                    }
                    .frame(width: 250)
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.top, 50)
                    .transition(.move(edge: .leading))
                }

                // Safari WebView for opening URL
                if showWebView, let urlString = urlToOpen, let url = URL(string: urlString) {
                    SafariView(url: url)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationBarTitle("Video Player", displayMode: .inline)
        }
    }

    // Play video function
    func playVideo(urlString: String) {
        if let url = URL(string: urlString) {
            player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.modalPresentationStyle = .fullScreen
            present(playerViewController)
        }
    }

    // Play playlist function
    func playPlaylist() {
        guard !playlist.isEmpty else { return }

        // Start playing the first video in the playlist
        playVideoFromPlaylist(index: currentVideoIndex)
    }

    // Play video from playlist
    func playVideoFromPlaylist(index: Int) {
        let urlString = playlist[index]
        if let url = URL(string: urlString) {
            player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.modalPresentationStyle = .fullScreen
            
            // Add observer to detect when video finishes playing
            playerObserver = player?.addBoundaryTimeObserver(forTimes: [NSValue(time: CMTimeMakeWithSeconds(1.0, preferredTimescale: 600))], queue: .main) {
                self.videoDidFinishPlaying()
            }
            
            present(playerViewController)
            player?.play()
        }
    }

    // When the video finishes playing
    func videoDidFinishPlaying() {
        // Move to the next video in the playlist
        if currentVideoIndex < playlist.count - 1 {
            currentVideoIndex += 1
            playVideoFromPlaylist(index: currentVideoIndex)
        } else {
            currentVideoIndex = 0 // Loop back to the start
            playVideoFromPlaylist(index: currentVideoIndex)
        }
    }

    // File picker function
    func pickFile(type: FileType) {
        let documentPicker: UIDocumentPickerViewController
        if type == .movie {
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.movie], asCopy: true)
        } else {
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
        }
        
        documentPicker.delegate = DocumentPickerCoordinator(parent: self)
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker)
    }

    func present(_ viewController: UIViewController) {
        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first })
            .first?.rootViewController {
            rootVC.present(viewController, animated: true)
        }
    }
    
    // Save playlist to UserDefaults
    func savePlaylist() {
        UserDefaults.standard.set(playlist, forKey: playlistKey)
    }

    // Add item to playlist
    func addToPlaylist(url: String) {
        playlist.append(url)
        savePlaylist()  // Save after adding
    }
    
    // Load playlist from URL
    func loadPlaylist(url: String) {
        if let playlistURL = URL(string: url) {
            // Here you can download the playlist, parse it (for example, M3U format),
            // and then update the playlist state with the URLs.
            // For simplicity, let's assume the playlist URL directly returns a list of video URLs.
            // In a real scenario, you would parse the playlist contents.
            
            // Mock loading playlist
            playlist.append("https://www.example.com/video1.mp4")
            playlist.append("https://www.example.com/video2.mp4")
            savePlaylist()
        }
    }
}

// Enum for file types
enum FileType {
    case movie, audio
}

// Playlist management view
struct PlaylistView: View {
    @Binding var playlist: [String]  // Bind to the playlist array
    var onLoad: (String) -> Void  // Callback to load playlist from URL
    var onAdd: (String) -> Void  // Callback to add item to playlist
    @State private var newPlaylistURL: String = ""

    var body: some View {
        VStack {
            // TextField to enter playlist URL
            TextField("Enter Playlist URL", text: $newPlaylistURL)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300)
            
            // Button to load the playlist from the entered URL
            Button("Load Playlist") {
                onLoad(newPlaylistURL)
            }
            .padding()
            .frame(width: 300)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(newPlaylistURL.isEmpty) // Disable if the URL field is empty

            // List to display current playlist
            List {
                ForEach(playlist, id: \.self) { video in
                    Text(video)
                }
            }
            .navigationBarTitle("Playlist", displayMode: .inline)
        }
        .navigationBarItems(trailing: Button(action: {
            addDummyItem()
        }) {
            Text("Add Item")
        })
    }
    
    // Add dummy item to playlist for testing
    func addDummyItem() {
        playlist.append("https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")
    }
}

// Safari WebView for URL opening
struct SafariView: View {
    var url: URL

    var body: some View {
        SafariViewController(url: url)
    }
}

struct SafariViewController: UIViewControllerRepresentable {
    var url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// Coordinator class for Document Picker and other integrations
class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    var parent: ContentView

    init(parent: ContentView) {
        self.parent = parent
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            if url.pathExtension == "mp4" || url.pathExtension == "mov" {
                parent.videoFileURL = url
            } else if url.pathExtension == "mp3" || url.pathExtension == "wav" {
                parent.audioFileURL = url
            }
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Handle cancellation if needed
    }
}

