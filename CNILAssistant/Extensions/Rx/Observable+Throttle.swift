

import Foundation
import RxSwift

extension ObservableType {
    static func throttle<O>(_ source: O,
                            dueTime: RxTimeInterval,
                            scheduler: SchedulerType) -> RxSwift.Observable<O.Element> where O: RxSwift.ObservableType {
        return Observable<O.Element>.zip(
            source,
            Observable<Int>.timer(dueTime, scheduler: scheduler),
            resultSelector: { myItem, _ in return myItem }
        )
    }
}
