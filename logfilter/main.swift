//
//  main.swift
//  logfilter
//
//  Created by Cristian Baluta on 21/04/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation

let keywords = "ActivityManager,ActivityUploadManager,significant_assistance_level_percentages".components(separatedBy: ",")
let input = "/Users/cristi/Downloads/debug 4.log"
let output: FileHandle? = FileHandle(forWritingAtPath: "/Users/cristi/Desktop/activityuploadwithinvalidtoken-filtered.log")


if freopen(input, "r", stdin) == nil {
    perror(input)
}
while let line = readLine() {
    for key in keywords {
        if line.contains(key) {
            print(line)
            let data = (line as NSString).data(using: String.Encoding.utf8.rawValue)
            output?.write(data!)
            break
        }
    }
}

output?.closeFile()
