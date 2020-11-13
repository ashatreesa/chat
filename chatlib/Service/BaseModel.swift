

import UIKit
import RxSwift
import Alamofire
import CoreData

extension Request: ReactiveCompatible {}

extension Reactive where Base: DataRequest {
    
    func responseJSON() -> Observable<Any> {
        return Observable.create { observer in
            let request = self.base.responseJSON { response in
                let statuscode = response.response?.statusCode
                switch response.result {
                    
                case .success(let value):
                    
                    observer.onNext(value)
                    observer.onCompleted()
                    
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create(with: request.cancel)
        }
    }
    
    
}

