

import Foundation

struct FileInfoDto: Decodable {
    let name: String
    let checkSumm: String

    enum CodingKeys: String, CodingKey {
        case name = "file"
        case checkSumm = "check_summ"
    }
}

struct ModelVersionDto: Decodable {
    let versionName: String
    let files: [FileInfoDto]

    enum CodingKeys: String, CodingKey {
        case versionName = "version_name"
        case files = "files"
    }
}
