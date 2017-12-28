//
//  Constants.swift
//  MT
//
//  Created by ILYA Abramovich on 24.12.2017.
//  Copyright © 2017 ILYA Abramovich. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let buttonColor = UIColor(red: 238 / 255, green: 101 / 255, blue: 121 / 255, alpha: 1)
    
    static let courses = ["Intro course","Second course","Third course"]
    
    /*
    // Dictionary [courseTitle: [courseDescription,
                                lesson1URL,
                                lesson2URL,
                                lesson3URL,
                                ...]
    */
    static let coursesDict = ["Intro course": ["",
                                           "http://muzmo.ru/get/music/20160726/muzmo_ru_Rick_Astley_-_Never_Gonna_Give_You_Up_36383490.mp3",
                                           "http://store.naitimp3.ru/download/676165/RDl0YXdWanNUU0t2TTQ5dDM2QTYwYnAwdXE2Q1FYNjhhb1dWR3VjcmpNWFBMdGQ3cC92Y3pYRjBjakp0cEFyL1ZDUFpBYVRhRFU3T0xjSG5RRlBpQ0lVTVQrbFBDUnZ5TDZ4ajM5dEhMWjg9/rick_astley_never_gonna_give_you_up_(NaitiMP3.ru).mp3",
                                           ""],
                         "Second course": ["",
                                           "",
                                           ""],
                          "Third course": ["",
                                           ""]]
    
    // Use when courseDescription = ""
    static let courseDescriptionDefault = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus"
    
}
