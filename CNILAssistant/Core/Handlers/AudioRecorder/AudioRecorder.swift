import Foundation
import AVFoundation

struct RecordError: Error, LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}

struct NoVoiceError: Error, LocalizedError {
    var errorDescription: String? {
        "No voice detected"
    }
}

class AudioRecorder: NSObject {
    struct Configuration {
        static let defaultSilenceThreshold: Float = -44.0
        static let defaultMaxPowerThreshold: Float = -10.0
        static let defaultVoiceThreshold: Float = -33.0

        let resultFileDirectoryURL: URL
        let intermediateFilesDirectoryURL: URL

        let voiceThreshold: Float
        let silenceThreshold: Float
        let maxPowerThreshold: Float

        init(
            resultFileDirectoryURL: URL? = nil,
            intermediateFilesDirectoryURL: URL? = nil,
            voiceThreshold: Float = defaultVoiceThreshold,
            silenceThreshold: Float = defaultSilenceThreshold,
            maxPowerThreshold: Float = defaultMaxPowerThreshold
        ) {
            self.intermediateFilesDirectoryURL = intermediateFilesDirectoryURL ?? FileManager.default.getCachesDirectory()
            self.resultFileDirectoryURL = resultFileDirectoryURL ?? FileManager.default.getCachesDirectory()
            self.voiceThreshold = voiceThreshold
            self.silenceThreshold = silenceThreshold
            self.maxPowerThreshold = maxPowerThreshold
        }
    }

    let configuration: Configuration

    fileprivate let audioRecorder: AVAudioRecorder

    fileprivate var recorderMetersTimer: Timer?
    fileprivate var statusForDetection: Double = 0.0

    fileprivate var recordingBeginTime: Date?
    fileprivate var startVoiceDetectionTime: Date?

    fileprivate var levelMonitor: ((Float) -> Void)?
    fileprivate var completion: ((Result<URL, Error>) -> Void)?

    init(configuration: Configuration = Configuration()) throws {
        self.configuration = configuration

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        recordingFileURL = configuration.intermediateFilesDirectoryURL.appendingPathComponent("recording.m4a")
        wavFileURL = configuration.resultFileDirectoryURL.appendingPathComponent("recording.wav")
        trimmedSoundFileURL = configuration.intermediateFilesDirectoryURL.appendingPathComponent("trimmedFileURL.mp4a")

        audioRecorder = try AVAudioRecorder(url: recordingFileURL, settings: settings)
        audioRecorder.isMeteringEnabled = true

        super.init()

        audioRecorder.delegate = self
    }

    private let recordingFileURL: URL
    private let wavFileURL: URL
    private let trimmedSoundFileURL: URL

    private let metersInterval = 0.1

    fileprivate var isCancelling: Bool = false
    fileprivate(set) var isRecording: Bool = false

    func record(duration: TimeInterval,
                delay: TimeInterval = 0.0,
                levelMonitor: @escaping (Float) -> Void,
                completion: @escaping (Result<URL, Error>) -> Void) {

        if isRecording {
            cancel()
        }

        isRecording = true

        self.levelMonitor = levelMonitor
        self.completion = completion

        let recordingBeginTime = self.audioRecorder.deviceCurrentTime + delay
        self.recordingBeginTime = Date() + delay

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, self.isRecording else {
                return
            }
            // record forDuration not working properly
            if !self.audioRecorder.record(atTime: recordingBeginTime) {
                self.completeRecording(result: .failure(RecordError(message: "Audio recording error")))
                return
            }
        }

        statusForDetection = 0.0
        recorderMetersTimer = Timer(timeInterval: metersInterval, repeats: true, block: { [weak self] _ in
            guard let self = self, self.audioRecorder.isRecording && self.audioRecorder.currentTime > 0 else {
                return
            }

            if Date().timeIntervalSince(self.startVoiceDetectionTime ?? self.recordingBeginTime!) >= duration {
                self.stop()
            }

            self.audioRecorder.updateMeters()
            let currentLevel = self.audioRecorder.averagePower(forChannel: 0)

            let microphoneLevel = MicrophoneLevel.normalized(
                currentLevel: currentLevel,
                voiceThreshold: self.configuration.voiceThreshold,
                maxDistribution: self.configuration.maxPowerThreshold,
                minDistribution: self.configuration.silenceThreshold)

            self.levelMonitor?(microphoneLevel)

            if currentLevel > self.configuration.voiceThreshold {
                self.statusForDetection = 0.0
                if self.startVoiceDetectionTime == nil {
                    self.startVoiceDetectionTime = Date()
                }
            } else {
                self.statusForDetection += 0.1

                if self.statusForDetection > 5.0 || (self.startVoiceDetectionTime != nil && self.statusForDetection > 2.0) {
                    self.statusForDetection = 0.0
                    self.stop()
                }
            }
        })
        RunLoop.main.add(recorderMetersTimer!, forMode: .common)
    }

    func stop() {
        if audioRecorder.isRecording {
            audioRecorder.stop()
        } else if isRecording {
            completeRecording(result: .failure(NoVoiceError()))
        }
    }

    func cancel() {
        if audioRecorder.isRecording {
            isCancelling = true
            audioRecorder.stop()
        }

        completeRecording(result: nil)
    }

    deinit {
        audioRecorder.delegate = nil
        cancel()
    }

    private func completeRecording(result: Result<URL, Error>?) {
        recorderMetersTimer?.invalidate()
        recorderMetersTimer = nil
        levelMonitor = nil

        audioRecorder.deleteRecording()

        startVoiceDetectionTime = nil
        recordingBeginTime = nil
        statusForDetection = 0.0

        isRecording = false

        let completion = self.completion
        self.completion = nil
        DispatchQueue.main.async {
            if let result = result {
                completion?(result)
            }
        }
    }

    private func trimAudio(inputFile: URL,
                           outputFileName: URL,
                           startCutTime: TimeInterval?,
                           endCutTime: TimeInterval?,
                           completion: @escaping (Error?) -> Void) {
        let asset = AVAsset(url: inputFile)

        try? FileManager.default.removeItem(at: outputFileName)

        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            completion(RecordError(message: "cannot create AVAssetExportSession for asset \(String(describing: asset))"))
            return
        }
        exporter.outputFileType = AVFileType.m4a
        exporter.outputURL = outputFileName

        var start: TimeInterval = 0.0

        if let startCutTime = startCutTime {
            start = max(0, startCutTime)
        }

        let duration = CMTimeGetSeconds(asset.duration)
        var endTime = duration
        if let endCutTime = endCutTime {
            endTime = min(duration, endCutTime)
        }

        let startTime =  CMTime(seconds: start, preferredTimescale: 10000)
        let stopTime =  CMTime(seconds: endTime, preferredTimescale: 10000)
        exporter.timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: stopTime)
        exporter.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async {
                completion(exporter.error)
            }
        })
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if isCancelling {
            isCancelling = false
            return
        }

        if flag {
            // Voice detected
            if let startVoiceDetectionTime = startVoiceDetectionTime {
                let startCutTime = startVoiceDetectionTime.timeIntervalSince(recordingBeginTime!) - metersInterval * 4
                trimAudio(
                    inputFile: self.recordingFileURL,
                    outputFileName: self.trimmedSoundFileURL,
                    startCutTime: startCutTime,
                    endCutTime: nil,
                    completion: { [weak self] error in
                        guard let self = self else { return }

                        try? FileManager.default.removeItem(at: self.wavFileURL)

                        if AudioToolboxUtils.convertAudio(self.trimmedSoundFileURL, outputURL: self.wavFileURL) != noErr {
                            self.completeRecording(result: .failure(RecordError(message: "Audio converting error")))
                            return
                        }
                        if let error = error {
                            self.completeRecording(result: .failure(error))
                        } else {
                            self.completeRecording(result: .success(self.wavFileURL))
                        }
                    })
            } else {
                completeRecording(result: .failure(NoVoiceError()))
            }
        } else {
            completeRecording(result: .failure(RecordError(message: "Audio encoding error")))
        }
    }
}
