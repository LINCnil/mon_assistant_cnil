import Foundation
import AudioToolbox

enum AudioToolboxUtils {
    static func convertAudio(_ url: URL, outputURL: URL) -> OSStatus {
        var error: OSStatus = noErr
        var destinationFile: ExtAudioFileRef?
        var sourceFile: ExtAudioFileRef?

        var srcFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
        var dstFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()

        ExtAudioFileOpenURL(url as CFURL, &sourceFile)

        var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: srcFormat))

        ExtAudioFileGetProperty(sourceFile!,
                                kExtAudioFileProperty_FileDataFormat,
                                &thePropertySize, &srcFormat)

        dstFormat.mSampleRate = 16000  // Set sample rate
        dstFormat.mFormatID = kAudioFormatLinearPCM
        dstFormat.mChannelsPerFrame = 1
        dstFormat.mBitsPerChannel = 16
        dstFormat.mBytesPerPacket = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mBytesPerFrame = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mFramesPerPacket = 1
        dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger

        // Create destination file
        error = ExtAudioFileCreateWithURL(
            outputURL as CFURL,
            kAudioFileWAVEType,
            &dstFormat,
            nil,
            AudioFileFlags.eraseFile.rawValue,
            &destinationFile)

        guard error == noErr else { return error }

        error = ExtAudioFileSetProperty(sourceFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)

        guard error == noErr else { return error }

        error = ExtAudioFileSetProperty(destinationFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)

        guard error == noErr else { return error }

        let bufferByteSize: UInt32 = 32768
        var srcBuffer = [UInt8](repeating: 0, count: Int(bufferByteSize))
        var sourceFrameOffset: ULONG = 0

        while true {
            var fillBufList = AudioBufferList(
                mNumberBuffers: 1,
                mBuffers: AudioBuffer(
                    mNumberChannels: 2,
                    mDataByteSize: UInt32(srcBuffer.count),
                    mData: &srcBuffer
                )
            )
            var numFrames: UInt32 = 0

            if dstFormat.mBytesPerFrame > 0 {
                numFrames = bufferByteSize / dstFormat.mBytesPerFrame
            }

            error = ExtAudioFileRead(sourceFile!, &numFrames, &fillBufList)

            guard error == noErr else { return error }

            if numFrames == 0 {
                error = noErr
                break
            }

            sourceFrameOffset += numFrames
            error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)

            guard error == noErr else { return error }
        }

        ExtAudioFileDispose(destinationFile!)
        ExtAudioFileDispose(sourceFile!)

        return error
    }
}
