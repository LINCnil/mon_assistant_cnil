

import Foundation

struct ModelVersionMapper {
    func map(versionDto: ModelVersionDto) throws -> RemoteModel {
        return RemoteModel(
            version: ModelVersion(versionName: versionDto.versionName),
            fileName: versionDto.files.first!.name,
            fileCheckSumm: versionDto.files.first!.checkSumm)
    }
}
