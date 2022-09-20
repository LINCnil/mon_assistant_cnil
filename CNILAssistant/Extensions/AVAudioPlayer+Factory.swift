
import Foundation
import AVFoundation

extension AVAudioPlayer {
    static func playerForSoundResource(_ resourceName: String, type: AVFileType, rate: Float = 1.0, numberOfLoops: Int = 0) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: type.fileExtension) else { return nil }

        do {
            let resourcePlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: type.rawValue)
            resourcePlayer.rate = rate
            resourcePlayer.numberOfLoops = numberOfLoops
            resourcePlayer.enableRate = true
            return resourcePlayer
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
