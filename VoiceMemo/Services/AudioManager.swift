import Foundation
import AVFoundation

class AudioManager: NSObject, ObservableObject {
    var audioPlayer: AVAudioPlayer?
    internal var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession = .sharedInstance()
    
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    private var timer: Timer?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session: \(error.localizedDescription)")
        }
    }
    
    func startRecording() -> URL? {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(Date().timeIntervalSince1970).m4a")
        print("Will save recording to: \(audioFilename.path)")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            return audioFilename
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
            return nil
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        print("Recording stopped")
    }
    
    func startPlaying(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            duration = audioPlayer?.duration ?? 0
            startPlaybackTimer()
        } catch {
            print("Could not start playing: \(error.localizedDescription)")
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
        currentTime = 0
        stopPlaybackTimer()
    }
    
    func pausePlaying() {
        audioPlayer?.pause()
        isPlaying = false
        stopPlaybackTimer()
    }
    
    private func startPlaybackTimer() {
        stopPlaybackTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
        }
    }
    
    private func stopPlaybackTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

extension AudioManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        print("Recording finished, success: \(flag)")
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        stopPlaybackTimer()
    }
} 