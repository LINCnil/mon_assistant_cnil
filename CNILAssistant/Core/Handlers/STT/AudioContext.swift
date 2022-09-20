import Foundation
import AVFoundation

enum AudioContextError: Error {
    case invalidAudioDescription
    case unknown(message: String)
}

extension AudioContextError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .unknown(message):
            return message
        case .invalidAudioDescription:
            return "Can not load audio format description"
        }
    }
}

final class AudioContext {

    /// The audio asset URL used to load the context
    let audioURL: URL

    /// Total number of samples in loaded asset
    let totalSamples: Int

    /// Loaded asset
    let asset: AVAsset

    // Loaded assetTrack
    let assetTrack: AVAssetTrack

    private init(audioURL: URL, totalSamples: Int, asset: AVAsset, assetTrack: AVAssetTrack) {
        self.audioURL = audioURL
        self.totalSamples = totalSamples
        self.asset = asset
        self.assetTrack = assetTrack
    }

    static func load(from audioURL: URL, completion: @escaping (Result<AudioContext, Error>) -> Void) {
        let asset = AVURLAsset(url: audioURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(value: true as Bool)])

        guard let assetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else {
            DispatchQueue.main.async {
                completion(.failure(AudioContextError.unknown(message: "Couldn't load AVAssetTrack")))
            }
            return
        }

        asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            let result: Result<AudioContext, Error>

            defer {
                DispatchQueue.main.async {
                    completion(result)
                }
            }

            var error: NSError?
            let status = asset.statusOfValue(forKey: "duration", error: &error)
            switch status {
            case .loaded:
                guard
                    let formatDescriptions = assetTrack.formatDescriptions as? [CMAudioFormatDescription],
                    let audioFormatDesc = formatDescriptions.first,
                    let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(audioFormatDesc)
                else {
                    result = .failure(AudioContextError.invalidAudioDescription)
                    return
                }

                let totalSamples = Int((asbd.pointee.mSampleRate) * Float64(asset.duration.value) / Float64(asset.duration.timescale))
                let audioContext = AudioContext(audioURL: audioURL, totalSamples: totalSamples, asset: asset, assetTrack: assetTrack)
                result = .success(audioContext)
            default:
                print("Couldn't load asset: \(error?.localizedDescription ?? "Unknown error")")
                result = .failure(error ?? AudioContextError.unknown(message: "Unknown Error"))
            }
        }
    }
}
