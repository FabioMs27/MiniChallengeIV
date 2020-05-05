//
//  LostTimeFocusBO.swift
//  MiniChallengeIV
//
//  Created by Caio Azevedo on 30/04/20.
//  Copyright © 2020 Murilo Teixeira. All rights reserved.
//

import Foundation

class TimeRecoverBO {
    var enterBackgroundInstant: Date?
    var returnFromBackgroundInstant: Date!
    
    var timer: TimeTracker
    
    init(timer: TimeTracker) {
        self.timer = timer
    }
    
    func enterbackground(){
        if timer.runningState == TimeTrackerState.focus {
            /// Save the moment that enterBackground
            self.enterBackgroundInstant = Date()
            
            print("EnterBackground Instant: \(enterBackgroundInstant)")
            
        } else if timer.runningState == TimeTrackerState.pause {
            /// Local Notification with rest Time as delay
        }
    }
    
    func returnFromBackground(){
        guard let backgroundInstant = self.enterBackgroundInstant else { return }
        
        let timeInBackground = backgroundTimeRecover(backgroundInstant: backgroundInstant)
        
        /// Handle Timer State
        if timer.runningState == .focus{
            updateTimerAtributesWhenFocus(lostFocusTime: timeInBackground)
        } else if timer.runningState == .pause{
            updateTimerAtributesWhenPause(restInBackgrund: timeInBackground)
        }
    }
    
    /// Description: Function to recover and update the timer or the esttistics
    func backgroundTimeRecover(backgroundInstant: Date) -> Int{
        self.returnFromBackgroundInstant = Date()
        
        /// Get the time the user has been out of the app
        let timeInBackground = Int(backgroundInstant.distance(to: self.returnFromBackgroundInstant))
        
        print("Came Back after : \(timeInBackground)")
        
        return timeInBackground
    }
    
    func updateTimerAtributesWhenFocus(lostFocusTime: Int) {
        let currentTime = lostFocusTime + timer.lostFocusTime + timer.focusTime
        
        /// If the user has been out more than the time he configured, change cicle of Timer
        if currentTime < timer.convertedTimeValue {
            /// Update lost focus time from timer with the value calculate when returns from background and the configured Time isnt over
            timer.lostFocusTime += (lostFocusTime)
            timer.countDown -= lostFocusTime
        } else {
            /// Update Timer - Lost Focus Time
            timer.lostFocusTime = timer.convertedTimeValue - timer.focusTime
            changeCicleTimer()
        }
    }
    
    func updateTimerAtributesWhenPause(restInBackgrund: Int) {
        let currentRestTime = restInBackgrund + timer.restTime
        
        /// If the user has been out more than the time he configured, change cicle of Timer
        if currentRestTime < timer.convertedTimeValue {
            /// Update Atributes
            timer.restTime += restInBackgrund
            timer.countDown -= restInBackgrund
        } else {
            timer.restTime = timer.convertedTimeValue
            changeCicleTimer()
        }
    }
    
    func changeCicleTimer() {
        ///Stop Timer
        timer.state = timer.changeCicle
        
        /// Restar timer
        timer.countDown = 0
        
        /// Update Estatistics on Database
        timer.updateStatistics()
    }
}
