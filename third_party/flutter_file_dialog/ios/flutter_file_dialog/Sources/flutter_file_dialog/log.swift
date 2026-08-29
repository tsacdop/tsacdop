// Copyright (c) 2020 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

import Foundation

#if DEBUG
func writeLog(_ item: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    print("\(Date()) [\((file as NSString).lastPathComponent):\(line) \(function)] \(item())")
}
#else
func writeLog(_ item: @autoclosure () -> Any) {}
#endif
