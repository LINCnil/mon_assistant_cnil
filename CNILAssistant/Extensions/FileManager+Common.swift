
import Foundation

extension FileManager {
    func getDocumentsDirectory() -> URL {
        let paths = self.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func getCachesDirectory() -> URL {
        let paths = self.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
    }

    func fileExists(at url: URL) -> Bool {
        return self.fileExists(atPath: url.path)
    }
}
