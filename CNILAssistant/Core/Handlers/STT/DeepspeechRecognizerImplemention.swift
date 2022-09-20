import Foundation
import AVFoundation
import deepspeech_ios

final class DeepspeechRecognizerImplemention: SpeechRecognizer {
    private let pipelineLogRepository: PipelineLogRepository?

    private let modelFileUrl: URL
    private let scorerFileUrl: URL

    init(modelFileUrl: URL, scorerFileUrl: URL, pipelineLogRepository: PipelineLogRepository?) {
        self.modelFileUrl = modelFileUrl
        self.scorerFileUrl = scorerFileUrl

        self.pipelineLogRepository = pipelineLogRepository
    }

    func recognizeAudio(url: URL, completion: @escaping (Result<String, Error>) -> Void) {
        AudioContext.load(from: url) { result in
            result.asyncMap(transform: self.performRecognition, completion: completion)
        }
    }

    // MARK: Audio file recognition

    private func performRecognition(audioContext: AudioContext, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global().async {
            let result: Result<String, Error>

            defer {
                DispatchQueue.main.async {
                    completion(result)
                }
            }

            do {
                // Create model in place instead of init to reduce memory usage
                let model = try DeepSpeechModel(modelPath: self.modelFileUrl.path)
                try model.enableExternalScorer(scorerPath: self.scorerFileUrl.path)
                let stream = try model.createStream()
                try self.render(audioContext: audioContext, stream: stream)

                var audioLogsDirectory: URL?
                let isAudioLogsEnabled = ApplicationSettings.shared.isAudioLogsEnabled
                if isAudioLogsEnabled {
                    let directory = FileManager.default.getDocumentsDirectory().appendingPathComponent("AudioLogs")
                    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                    audioLogsDirectory = directory
                }
                let res = stream.finishStream(pathToSaveAudio: audioLogsDirectory?.path ?? "")
                print(res)
                self.pipelineLogRepository?.log(entry: "stt result: \"\(res)\"", for: .stt)
                result = .success(res)
            } catch {
                result = .failure(error)
            }
        }
    }

    private func render(audioContext: AudioContext, stream: DeepSpeechStream) throws {
        let sampleRange: CountableRange<Int> = 0..<audioContext.totalSamples
        let reader = try AVAssetReader(asset: audioContext.asset)

        reader.timeRange = CMTimeRange(
            start: CMTime(
                value: Int64(sampleRange.lowerBound),
                timescale: audioContext.asset.duration.timescale),
            duration: CMTime(value: Int64(sampleRange.count), timescale: audioContext.asset.duration.timescale))

        let outputSettingsDict: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]

        let readerOutput = AVAssetReaderTrackOutput(track: audioContext.assetTrack,
                                                    outputSettings: outputSettingsDict)
        readerOutput.alwaysCopiesSampleData = false
        reader.add(readerOutput)

        var sampleBuffer = Data()

        // 16-bit samples
        reader.startReading()
        defer { reader.cancelReading() }

        while reader.status == .reading {
            guard let readSampleBuffer = readerOutput.copyNextSampleBuffer(),
                  let readBuffer = CMSampleBufferGetDataBuffer(readSampleBuffer) else {
                break
            }
            // Append audio sample buffer into our current sample buffer
            var readBufferLength = 0
            var readBufferPointer: UnsafeMutablePointer<Int8>?
            CMBlockBufferGetDataPointer(readBuffer,
                                        atOffset: 0,
                                        lengthAtOffsetOut: &readBufferLength,
                                        totalLengthOut: nil,
                                        dataPointerOut: &readBufferPointer)
            sampleBuffer.append(UnsafeBufferPointer(start: readBufferPointer, count: readBufferLength))
            CMSampleBufferInvalidate(readSampleBuffer)

            let totalSamples = sampleBuffer.count / MemoryLayout<Int16>.size
            print("read \(totalSamples) samples")

            sampleBuffer.withUnsafeBytes { (samples: UnsafeRawBufferPointer) in
                let unsafeBufferPointer = samples.bindMemory(to: Int16.self)
                stream.feedAudioContent(buffer: unsafeBufferPointer)
            }

            sampleBuffer.removeAll()
        }

        // if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown)
        guard reader.status == .completed else {
            fatalError("Couldn't read the audio file")
        }
    }
}
