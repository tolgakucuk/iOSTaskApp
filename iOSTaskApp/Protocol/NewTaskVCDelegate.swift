//
//  TasksVCDelegate.swift
//  iOSTaskApp
//
//  Created by Tolga on 16.03.2022.
//

import Foundation

protocol NewTaskVCDelegate: AnyObject {
    func didAddTask(_ task: Task)
    func didEditTask(_ task: Task)
}
