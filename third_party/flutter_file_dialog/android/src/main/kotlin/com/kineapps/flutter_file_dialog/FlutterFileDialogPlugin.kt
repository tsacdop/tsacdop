// Copyright (c) 2020 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

package com.kineapps.flutter_file_dialog

import android.app.Activity
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterFileDialogPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {
    private var fileDialog: FileDialog? = null
    private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var methodChannel: MethodChannel? = null

    companion object {
        const val LOG_TAG = "FlutterFileDialogPlugin"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(LOG_TAG, "onAttachedToEngine - IN")

        if (pluginBinding != null) {
            Log.w(LOG_TAG, "onAttachedToEngine - already attached")
        }

        pluginBinding = binding

        pluginBinding?.binaryMessenger?.let { doOnAttachedToEngine(it) }

        Log.d(LOG_TAG, "onAttachedToEngine - OUT")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(LOG_TAG, "onDetachedFromEngine")
        doOnDetachedFromEngine()
    }

    // note: this may be called multiple times on app startup
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(LOG_TAG, "onAttachedToActivity")
        doOnAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        Log.d(LOG_TAG, "onDetachedFromActivity")
        doOnDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(LOG_TAG, "onReattachedToActivityForConfigChanges")

        if (fileDialog != null) {
            this.activityBinding = binding
            fileDialog!!.setActivity(binding.activity)
        } else {
            doOnAttachedToActivity(binding)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(LOG_TAG, "onDetachedFromActivityForConfigChanges")
        this.activityBinding = null
        if (fileDialog != null) {
            fileDialog!!.setActivity(null)
        }
    }

    private fun doOnAttachedToEngine(messenger: BinaryMessenger) {
        Log.d(LOG_TAG, "doOnAttachedToEngine - IN")

        methodChannel = MethodChannel(messenger, "flutter_file_dialog").apply {
            setMethodCallHandler(this@FlutterFileDialogPlugin)
        }

        Log.d(LOG_TAG, "doOnAttachedToEngine - OUT")
    }

    private fun doOnDetachedFromEngine() {
        Log.d(LOG_TAG, "doOnDetachedFromEngine - IN")

        if (pluginBinding == null) {
            Log.w(LOG_TAG, "doOnDetachedFromEngine - already detached")
        }
        pluginBinding = null

        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        Log.d(LOG_TAG, "doOnDetachedFromEngine - OUT")
    }

    private fun doOnAttachedToActivity(activityBinding: ActivityPluginBinding?) {
        Log.d(LOG_TAG, "doOnAttachedToActivity - IN")

        // remove a previously registered FileDialog from the old binding so
        // stale listeners cannot process dialog results, and resolve its
        // pending result (if any) so the Dart future does not hang
        if (fileDialog != null) {
            this.activityBinding?.removeActivityResultListener(fileDialog!!)
            fileDialog!!.cancelPendingResult()
            fileDialog = null
        }

        this.activityBinding = activityBinding
        activityBinding?.let { createFileDialog(it) }

        Log.d(LOG_TAG, "doOnAttachedToActivity - OUT")
    }

    private fun doOnDetachedFromActivity() {
        Log.d(LOG_TAG, "doOnDetachedFromActivity - IN")

        if (fileDialog != null) {
            activityBinding?.removeActivityResultListener(fileDialog!!)
            fileDialog!!.cancelPendingResult()
            fileDialog = null
        }
        activityBinding = null

        Log.d(LOG_TAG, "doOnDetachedFromActivity - OUT")
    }


    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(LOG_TAG, "onMethodCall - IN , method=${call.method}")
        if (activityBinding == null) {
            result.error("init_failed", "Not attached to activity", null)
            return
        }
        when (call.method) {
            "pickDirectory" -> fileDialog!!.pickDirectory(result)
            "isPickDirectorySupported" -> fileDialog!!.isPickDirectorySupported(result)
            "saveFileToDirectory" -> saveFileToDirectory(
                    result,
                    mimeType = call.argument("mimeType") as String?,
                    fileName = call.argument("fileName") as String?,
                    directory = call.argument("directory") as String?,
                    data = call.argument("data") as ByteArray?,
            )
            "pickFile" -> fileDialog!!.pickFile(
                    result,
                    fileExtensionsFilter = parseMethodCallArrayArgument(call, "fileExtensionsFilter"),
                    mimeTypesFilter = parseMethodCallArrayArgument(call, "mimeTypesFilter"),
                    localOnly = call.argument("localOnly") as Boolean? == true,
                    copyFileToCacheDir = call.argument("copyFileToCacheDir") as Boolean? != false
            )
            "saveFile" -> fileDialog!!.saveFile(
                    result,
                    sourceFilePath = call.argument("sourceFilePath"),
                    data = call.argument("data"),
                    fileName = call.argument("fileName"),
                    mimeTypesFilter = parseMethodCallArrayArgument(call, "mimeTypesFilter"),
                    localOnly = call.argument("localOnly") as Boolean? == true
            )
            else -> result.notImplemented()
        }
    }

    private fun saveFileToDirectory(
            result: Result,
            directory: String?,
            mimeType: String?,
            fileName: String?,
            data: ByteArray?,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            result.error(
                    "minimum_target",
                    "saveFileToDirectory() available only on Android 21 and above",
                    ""
            )
            return
        }

        Log.d(LOG_TAG, "saveFileToDirectory - IN")

        if (directory.isNullOrEmpty()) {
            result.error("invalid_arguments", "Missing 'directory'", null)
            return
        }

        if (mimeType.isNullOrEmpty()) {
            result.error("invalid_arguments", "Missing 'mimeType'", null)
            return
        }

        if (fileName.isNullOrEmpty()) {
            result.error("invalid_arguments", "Missing 'fileName'", null)
            return
        }

        if (data == null) {
            result.error("invalid_arguments", "Missing 'data'", null)
            return
        }

        activityBinding?.activity?.let { activity ->
            val dirURI: Uri = Uri.parse(directory)
            val outputFolder: DocumentFile? = DocumentFile.fromTreeUri(activity, dirURI)
            val newFile = outputFolder?.createFile(mimeType, fileName)
            newFile?.uri?.let { writeFile(activity, data, it) }
            result.success(newFile?.uri?.path)
        }

        Log.d(LOG_TAG, "saveFileToDirectory - OUT")
    }

    private fun writeFile(
            activity: Activity,
            data: ByteArray,
            destinationFileUri: Uri
    ) {
        activity.contentResolver.openOutputStream(destinationFileUri).use { outputStream ->
            outputStream as java.io.FileOutputStream
            outputStream.channel.truncate(0)
            outputStream.write(data)
        }
        Log.d(LOG_TAG, "Saved file to '${destinationFileUri.path}'")
    }

    private fun createFileDialog(activityBinding: ActivityPluginBinding) {
        Log.d(LOG_TAG, "createFileDialog - IN")

        val fileDialog = FileDialog(activity = activityBinding.activity)
        activityBinding.addActivityResultListener(fileDialog)
        this.fileDialog = fileDialog

        Log.d(LOG_TAG, "createFileDialog - OUT")
    }

    private fun parseMethodCallArrayArgument(call: MethodCall, arg: String): Array<String>? {
        if (call.hasArgument(arg)) {
            return call.argument<ArrayList<String>>(arg)?.toTypedArray()
        }
        return null
    }
}
