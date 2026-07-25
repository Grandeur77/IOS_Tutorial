import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var successPlayer: AVAudioPlayer?
    private var failurePlayer: AVAudioPlayer?
    
    private init() {
        prepareSoundFiles()
    }
    
    private func prepareSoundFiles() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let successURL = documentsURL.appendingPathComponent("success.wav")
        let failureURL = documentsURL.appendingPathComponent("failure.wav")
        
        // Generate success WAV if not exists
        if !fileManager.fileExists(atPath: successURL.path) {
            generateWavFile(at: successURL, frequency: 650.0, duration: 0.12, isBuzzer: false)
        }
        
        // Generate failure WAV if not exists
        if !fileManager.fileExists(atPath: failureURL.path) {
            generateWavFile(at: failureURL, frequency: 180.0, duration: 0.35, isBuzzer: true)
        }
        
        // Load success audio player
        successPlayer = try? AVAudioPlayer(contentsOf: successURL)
        successPlayer?.prepareToPlay()
        
        // Load failure audio player
        failurePlayer = try? AVAudioPlayer(contentsOf: failureURL)
        failurePlayer?.prepareToPlay()
    }
    
    func playSuccess() {
        guard UserDefaults.standard.bool(forKey: "GameSoundsEnabled") != false else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            self.successPlayer?.currentTime = 0
            self.successPlayer?.play()
        }
    }
    
    func playFailure() {
        guard UserDefaults.standard.bool(forKey: "GameSoundsEnabled") != false else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            self.failurePlayer?.currentTime = 0
            self.failurePlayer?.play()
        }
    }
    
    // Programmatically generates a 16-bit PCM WAV file containing synthesized audio wave shapes
    private func generateWavFile(at url: URL, frequency: Double, duration: Double, isBuzzer: Bool) {
        let sampleRate = 44100
        let numSamples = Int(Double(sampleRate) * duration)
        let numChannels = 1
        let bitsPerSample = 16
        
        let headerSize = 44
        let dataSize = numSamples * numChannels * (bitsPerSample / 8)
        let fileSize = headerSize + dataSize - 8
        
        var header = Data()
        
        // RIFF descriptor
        header.append(Data("RIFF".utf8))
        header.append(withUnsafeBytes(of: Int32(fileSize).littleEndian) { Data($0) })
        header.append(Data("WAVE".utf8))
        
        // fmt subchunk
        header.append(Data("fmt ".utf8))
        header.append(withUnsafeBytes(of: Int32(16).littleEndian) { Data($0) }) // Subchunk1Size
        header.append(withUnsafeBytes(of: Int16(1).littleEndian) { Data($0) }) // AudioFormat (PCM = 1)
        header.append(withUnsafeBytes(of: Int16(numChannels).littleEndian) { Data($0) }) // NumChannels
        header.append(withUnsafeBytes(of: Int32(sampleRate).littleEndian) { Data($0) }) // SampleRate
        
        let byteRate = sampleRate * numChannels * (bitsPerSample / 8)
        header.append(withUnsafeBytes(of: Int32(byteRate).littleEndian) { Data($0) }) // ByteRate
        
        let blockAlign = numChannels * (bitsPerSample / 8)
        header.append(withUnsafeBytes(of: Int16(blockAlign).littleEndian) { Data($0) }) // BlockAlign
        header.append(withUnsafeBytes(of: Int16(bitsPerSample).littleEndian) { Data($0) }) // BitsPerSample
        
        // data subchunk descriptor
        header.append(Data("data".utf8))
        header.append(withUnsafeBytes(of: Int32(dataSize).littleEndian) { Data($0) }) // Subchunk2Size
        
        // Synthesize PCM samples
        var pcmData = Data()
        for i in 0..<numSamples {
            let t = Double(i) / Double(sampleRate)
            var sample: Double
            if isBuzzer {
                // Square wave buzzer
                sample = sin(2.0 * .pi * frequency * t) >= 0.0 ? 0.25 : -0.25
            } else {
                // Sine wave beep with linear decay envelope
                let envelope = 1.0 - (Double(i) / Double(numSamples))
                sample = sin(2.0 * .pi * frequency * t) * 0.35 * envelope
            }
            
            let intSample = Int16(max(-32768, min(32767, sample * 32767.0)))
            pcmData.append(withUnsafeBytes(of: intSample.littleEndian) { Data($0) })
        }
        
        var fullFile = Data()
        fullFile.append(header)
        fullFile.append(pcmData)
        
        try? fullFile.write(to: url)
    }
}
