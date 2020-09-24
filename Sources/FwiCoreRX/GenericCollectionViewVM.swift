//  File name   : GenericCollectionViewVM.swift
//
//  Author      : Phuc Tran
//  Created date: 7/15/18
//  --------------------------------------------------------------
//  Copyright © 2012, 2019 Fiision Studio. All Rights Reserved.
//  --------------------------------------------------------------
//
//  Permission is hereby granted, free of charge, to any person obtaining  a  copy
//  of this software and associated documentation files (the "Software"), to  deal
//  in the Software without restriction, including without limitation  the  rights
//  to use, copy, modify, merge,  publish,  distribute,  sublicense,  and/or  sell
//  copies of the Software,  and  to  permit  persons  to  whom  the  Software  is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF  ANY  KIND,  EXPRESS  OR
//  IMPLIED, INCLUDING BUT NOT  LIMITED  TO  THE  WARRANTIES  OF  MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO  EVENT  SHALL  THE
//  AUTHORS OR COPYRIGHT HOLDERS  BE  LIABLE  FOR  ANY  CLAIM,  DAMAGES  OR  OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING  FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN  THE
//  SOFTWARE.
//
//
//  Disclaimer
//  __________
//  Although reasonable care has been taken to  ensure  the  correctness  of  this
//  software, this software should never be used in any application without proper
//  testing. Fiision Studio disclaim  all  liability  and  responsibility  to  any
//  person or entity with respect to any loss or damage caused, or alleged  to  be
//  caused, directly or indirectly, by the use of this software.

#if canImport(UIKit) && !os(watchOS)
    import RxSwift
    import UIKit

    open class GenericCollectionViewVM<T: Equatable>: CollectionViewVM {
        /// Class's public properties.
        public var currentOptionalItem: Observable<T?> {
            return currentItemSubject.asObservable()
        }

        public var currentItem: Observable<T> {
            return currentItemSubject.asObservable().flatMap { item -> Observable<T> in
                guard let item = item else {
                    return Observable<T>.empty()
                }
                return Observable<T>.just(item)
            }
        }

        open var items: ArraySlice<T>?

        // MARK: Class's public methods
        override open func setupRX() {
            super.setupRX()

            disposeBag?.insert(
                currentOptionalIndexPath.map { [weak self] (indexPath) -> T? in
                    guard let indexPath = indexPath else {
                        return nil
                    }
                    return self?.items?[indexPath.row]
                }
                .bind(onNext: currentItemSubject.onNext)
            )
        }

        open func deselect(item: T?) {
            if let item = item {
                deselect(item: item)
            }
        }

        open func deselect(item: T) {
            if let index = items?.firstIndex(where: { $0 == item }) {
                deselect(itemAt: index)
            }
        }

        open func select(item: T?, scrollPosition: UICollectionView.ScrollPosition = .centeredHorizontally) {
            if let item = item {
                select(item: item, scrollPosition: scrollPosition)
            }
        }

        open func select(item: T, scrollPosition: UICollectionView.ScrollPosition = .centeredHorizontally) {
            if let index = items?.firstIndex(where: { $0 == item }) {
                select(itemAt: index, scrollPosition: scrollPosition)
            }
        }

        // MARK: UICollectionViewDataSource's members
        override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return count
        }

        override open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            items?.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        }

        /// Class's private properties.
        private let currentItemSubject = ReplaySubject<T?>.create(bufferSize: 1)
    }

    // MARK: Class's subscript
    extension GenericCollectionViewVM {
        open var count: Int {
            return items?.count ?? 0
        }

        @available(*, deprecated, message: "Will be removed in next version.")
        open subscript(index: Int) -> T? {
            guard index >= 0, index < count else {
                return nil
            }
            return items?[index]
        }

        @available(*, deprecated, message: "Will be removed in next version.")
        open subscript(index: IndexPath) -> T? {
            guard index.row >= 0, index.row < count else {
                return nil
            }
            return items?[index.row]
        }
    }
#endif
