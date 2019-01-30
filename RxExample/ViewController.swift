//
//  ViewController.swift
//  RxExample
//
//  Created by ByoungHoon Yun on 29/01/2019.
//  Copyright © 2019 Redvelvet Ventures Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet var numberButtons: [UIButton]!
    
    @IBOutlet weak var FL: UILabel!
    @IBOutlet weak var SL: UILabel!
    @IBOutlet weak var RL: UILabel!
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        test4()
    }
    
    func test1() {
        
        let numberObservables: [Observable<Int>] = numberButtons.enumerated().map { (index, button) in
            button.rx.tap.map{ index }
        }
        let numberObservable = Observable<Int>.merge(numberObservables)
        
        let firstNumberObservalble = numberObservable.take(1)
        let secondNumberObservalble = numberObservable.skip(1).take(1)
        
        
        firstNumberObservalble.map{"\($0)"}.bind(to: FL.rx.text).disposed(by: disposeBag)
        secondNumberObservalble.map{"\($0)"}.bind(to: SL.rx.text).disposed(by: disposeBag)
        
        
        secondNumberObservalble
            .withLatestFrom(firstNumberObservalble) { (first, second) -> Int in
                return first * second
            }.map{"\($0)"}
            .bind(to: RL.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    func test2() {
        
        let numberObservables: [Observable<Int>] = numberButtons.enumerated().map { (index, button) in
            button.rx.tap.map{ index }
        }
        let numberObservable = Observable<Int>.merge(numberObservables)
        
        let firstNumberObservalble = numberObservable.enumerated().filter { (index, _) -> Bool in
            return index % 2 == 0
            }.map { (_, number) in return number}
        let secondNumberObservalble = numberObservable.enumerated().filter { (index, _) -> Bool in
            return index % 2 == 1
            }.map { (_, number) in return number}
        
        firstNumberObservalble.map{"\($0)"}.bind(to: FL.rx.text).disposed(by: disposeBag)
        secondNumberObservalble.map{"\($0)"}.bind(to: SL.rx.text).disposed(by: disposeBag)
        
        
        secondNumberObservalble
            .withLatestFrom(firstNumberObservalble) { (first, second) -> Int in
                return first * second
            }.map{"\($0)"}
            .bind(to: RL.rx.text)
            .disposed(by: disposeBag)
        
    }

    func test3() {
        
        let numberObservables: [Observable<Int>] = numberButtons.enumerated().map { (index, button) in
            button.rx.tap.map{ index }
        }
        let numberObservable = Observable<Int>.merge(numberObservables).share()
        
        let firstNumberObservalble = numberObservable.enumerated().filter { (index, _) -> Bool in
            return index % 2 == 0
            }.map { (_, number) in return number}
        let secondNumberObservalble = numberObservable.enumerated().filter { (index, _) -> Bool in
            return index % 2 == 1
            }.map { (_, number) in return number}
        
        firstNumberObservalble.map{"\($0)"}.bind(to: FL.rx.text).disposed(by: disposeBag)
        secondNumberObservalble.map{"\($0)"}.bind(to: SL.rx.text).disposed(by: disposeBag)

        
        let answerObservable = numberObservable
            .window(timeSpan: 3600*24, count: 5, scheduler: MainScheduler.instance)
            .flatMap { window -> Observable<Int> in
                let answer = window.scan(0) { (answer, event) -> Int in
                    print("answer : \(answer)")
                    print("event : \(event)")
                    return answer * 10 + event
                }
                return answer
        }
        answerObservable.map{ "\($0)" }
            .bind(to: RL.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    func test4() {
        let timer = startButton.rx.tap
            .do(onNext: { _ in
                print("view init")
            }).flatMap { _ in
                Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                    .map { _ in arc4random_uniform(9) + 1 }
                    .take(5)
            }
        
        timer.subscribe(onNext: { (value) in
            print(value)
        }).disposed(by: disposeBag)
        
        timer.subscribe(onNext: { (value) in
            print(value)
        }).disposed(by: disposeBag)
    }

}

