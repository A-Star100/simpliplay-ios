import SwiftUI
import AVKit
import SafariServices
import UIKit

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
    @State private var customURL: String = ""  // For custom URL input

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

                    // Clear Video URL button
                    Button("Clear Video URL") {
                        videoURL = ""  // Clear the video URL
                    }
                    .padding()
                    .frame(width: 300)
                    .foregroundColor(.red)

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

                    // Add custom URL to playlist
                    VStack {
                        TextField("Enter Custom URL", text: $customURL)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 300)

                        Button("Add to Playlist") {
                            addCustomURLToPlaylist(url: customURL)
                        }
                        .padding()
                        .frame(width: 300)
                    }
                    
                    // Side menu button
                    Button("Open Menu") {
                        isMenuOpen.toggle()
                    }
                    .padding()

                    Spacer()
                    
                    // Playlist Button
                    NavigationLink(destination: PlaylistView(playlist: $playlist, onLoad: loadPlaylist, onAdd: addToPlaylist, onDelete: deleteFromPlaylist)) {
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
            .navigationBarTitle("SimpleiOSPlayer", displayMode: .inline)
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
        
        let coordinator = DocumentPickerCoordinator(parent: self)
        documentPicker.delegate = coordinator
        
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

    // Add custom URL to the playlist
    func addCustomURLToPlaylist(url: String) {
        // Make sure URL is valid
        if let validURL = URL(string: url), UIApplication.shared.canOpenURL(validURL) {
            playlist.append(url)
            savePlaylist()  // Save after adding
        }
    }
    
    // Load playlist from URL
    func loadPlaylist(url: String) {
        if let playlistURL = URL(string: url) {
            // Mock loading playlist
            downloadAndParseM3U(from: playlistURL)
        }
    }

    // Parse M3U playlist and add items to the playlist
    func downloadAndParseM3U(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error downloading playlist")
                return
            }

            if let playlistText = String(data: data, encoding: .utf8) {
                let urls = self.parseM3U(playlistText)
                DispatchQueue.main.async {
                    self.playlist = urls
                    self.savePlaylist()
                }
            }
        }
        task.resume()
    }

    // Simple M3U Parser
    func parseM3U(_ text: String) -> [String] {
        let lines = text.split(separator: "\n")
        var urls: [String] = []

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedLine.isEmpty && !trimmedLine.hasPrefix("#") {
                urls.append(String(trimmedLine))
            }
        }

        return urls
    }

    // Delete item from playlist
    func deleteFromPlaylist(at index: Int) {
        playlist.remove(at: index)
        savePlaylist()  // Save after deleting
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
    var onDelete: (Int) -> Void  // Callback to delete item from playlist
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
                ForEach(playlist.indices, id: \.self) { index in
                    HStack {
                        Text(playlist[index])
                        Spacer()
                        Button(action: {
                            onDelete(index)
                        }) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationBarTitle("Playlist", displayMode: .inline)
        }
        .navigationBarItems(trailing: Button(action: {
            // Replace this with adding custom URL to playlist
            onAdd(newPlaylistURL)
        }) {
            Text("Add Item")
        })
    }
}

// Safari WebView for URL opening
struct SafariView: View {
    var url: URL
    
    var body: some View {
        SafariViewController(url: url)
            .edgesIgnoringSafeArea(.all) // Make it full screen
    }
}

// Safari WebView Controller (UIKit Wrapper)
struct SafariViewController: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No update needed for this view controller
    }
}

// Document Picker Coordinator (Delegate)
class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    var parent: ContentView
    
    init(parent: ContentView) {
        self.parent = parent
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Handle file selection
        if let url = urls.first {
            if url.pathExtension == "mp4" || url.pathExtension == "mov" {
                parent.videoFileURL = url
            } else if url.pathExtension == "mp3" || url.pathExtension == "m4a" {
                parent.audioFileURL = url
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Handle cancellation
        print("Document picker was cancelled")
    }
}

