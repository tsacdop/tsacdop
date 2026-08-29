// Copyright (c) 2020 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

import Flutter
import Foundation
import UIKit

class SaveFileDialog: NSObject, UIDocumentPickerDelegate {
    private var flutterResult: FlutterResult?
    private var params: SaveFileDialogParams?
    private var tempFileUrl: URL?

    deinit {
        writeLog("")
        deleteTempFile()
    }

    func saveFileToDirectory(_ params: SaveFileToDirectoryParams, result: @escaping FlutterResult) {
        if params.data == nil {
            result(FlutterError(code: "invalid_arguments",
                                message: "Missing 'data'",
                                details: nil)
            )
            return
        }

        if params.directory == nil {
            result(FlutterError(code: "invalid_arguments",
                                message: "Missing 'directory'",
                                details: nil)
            )
            return
        }

        var directory: URL?
        do {
            var isStale = false
            directory = try URL(resolvingBookmarkData: Data(base64Encoded: params.directory!)!, bookmarkDataIsStale: &isStale)
            if (isStale) {
                result(FlutterError(code: "accessing_stale",
                                    message: "picked directory accessing staled",
                                    details: nil)
                )
                return
            }
        } catch let error {
            result(FlutterError(code: "invalid_arguments",
                                message: "invalid 'directory' data",
                                details: error.localizedDescription)
            )
            return
        }

        if params.fileName == nil || params.fileName!.isEmpty {
            result(FlutterError(code: "invalid_arguments",
                                message: "Missing 'fileName'",
                                details: nil)
            )
            return
        }

        let fileUrl = directory!.appendingPathComponent(params.fileName!, isDirectory: false)

        if FileManager.default.fileExists(atPath: fileUrl.path) {
            if !params.replace {
                result(FlutterError(code: "file_already_exists",
                                    message: "File already exists: '\(fileUrl.absoluteString)'",
                                    details: nil)
                )
                return
            }

            do {
                try FileManager.default.removeItem(at: fileUrl)
            } catch let error {
                result(FlutterError(code: "file_remove_failed",
                                    message: error.localizedDescription,
                                    details: nil)
                )
                return
            }
        }

        let fileContents = Data(bytes: params.data!, count: params.data!.count)
        do {
            try fileContents.write(to: fileUrl)
        } catch {
            result(FlutterError(code: "file_create_failed",
                                message: error.localizedDescription,
                                details: nil)
            )
            return
        }

        result(fileUrl.path)
    }

    func saveFile(_ params: SaveFileDialogParams, result: @escaping FlutterResult) {
        flutterResult = result
        self.params = params

        var fileUrl: URL?

        if params.data == nil {
            // get source file URL
            guard let sourceFilePath = params.sourceFilePath else {
                result(FlutterError(code: "invalid_arguments",
                                    message: "Missing 'sourceFilePath'",
                                    details: nil)
                )
                return
            }

            // note: fileExists fails if path contains relative elements, so standardize the path
            fileUrl = URL(fileURLWithPath: sourceFilePath).standardized

            // check that source file exists
            if !FileManager.default.fileExists(atPath: fileUrl!.path) {
                result(FlutterError(code: "file_not_found",
                                    message: "File not found: '\(fileUrl!.path)'",
                                    details: nil)
                )
                return
            }
        }

        // if file name was specified, create a temp file with the requested file name
        if params.fileName != nil {
            let directory = NSTemporaryDirectory()
            tempFileUrl = NSURL.fileURL(withPathComponents: [directory, params.fileName!])

            do {
                // overwrite existing file
                if FileManager.default.fileExists(atPath: tempFileUrl!.path) {
                    try FileManager.default.removeItem(at: tempFileUrl!)
                }

                if params.data != nil {
                    writeLog("Writing data \(params.data!.count) bytes to temp file \(tempFileUrl!)")
                    let d = Data(bytes: params.data!, count: params.data!.count)
                    try d.write(to: tempFileUrl!)
                } else {
                    writeLog("Copying \(fileUrl!) to \(tempFileUrl!)")
                    try FileManager.default.copyItem(at: fileUrl!, to: tempFileUrl!)
                }
            } catch {
                writeLog(error.localizedDescription)
                result(FlutterError(code: "creating_temp_file_failed",
                                    message: error.localizedDescription,
                                    details: nil)
                )
                return
            }
            fileUrl = tempFileUrl!
        }

        // get parent view controller
        guard let parentViewController = UIApplication.shared.keyWindow?.rootViewController else {
            result(FlutterError(code: "fatal",
                                message: "Getting rootViewController failed",
                                details: nil)
            )
            return
        }

        // create document picker
        let documentPickerViewController = UIDocumentPickerViewController(url: fileUrl!, in: .exportToService)
        documentPickerViewController.delegate = self

        // show dialog
        parentViewController.present(documentPickerViewController, animated: true, completion: nil)
    }

    private func deleteTempFile() {
        if tempFileUrl != nil {
            do {
                if FileManager.default.fileExists(atPath: tempFileUrl!.path) {
                    writeLog("Deleting temp file \(tempFileUrl!)")
                    try FileManager.default.removeItem(at: tempFileUrl!)
                }
                tempFileUrl = nil
            } catch {
                writeLog(error.localizedDescription)
            }
        }
    }

    // MARK: - UIDocumentPickerDelegate

    public func documentPicker(_: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        writeLog("didPickDocumentAt")
        deleteTempFile()
        flutterResult?(url.path)
    }

    public func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        writeLog("didPickDocumentsAt")
        deleteTempFile()
        flutterResult?(urls[0].path)
    }

    public func documentPickerWasCancelled(_: UIDocumentPickerViewController) {
        writeLog("documentPickerWasCancelled")
        deleteTempFile()
        flutterResult?(nil)
    }
}
