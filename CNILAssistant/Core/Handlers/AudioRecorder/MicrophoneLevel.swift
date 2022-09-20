import Foundation

enum MicrophoneLevel {
    static func normalized(currentLevel: Float, voiceThreshold: Float, maxDistribution: Float, minDistribution: Float) -> Float {
        let micLevelThreshDelta: Float = 15.0
        let micLevelMaxDistribution: Float = min(maxDistribution, voiceThreshold + micLevelThreshDelta * 2)
        let micLevelMinDistribution: Float = max(minDistribution, voiceThreshold - micLevelThreshDelta)

        var microphoneLevel: Float

        switch currentLevel {
        case _ where currentLevel > maxDistribution:
            microphoneLevel = 1
        case _ where currentLevel < minDistribution:
            microphoneLevel = 0
        default:
            let normalDistributed = (currentLevel - micLevelMinDistribution) / (micLevelMaxDistribution - micLevelMinDistribution)
            microphoneLevel = min(1.0, max(0.0, normalDistributed))
        }

        return microphoneLevel
    }
}
