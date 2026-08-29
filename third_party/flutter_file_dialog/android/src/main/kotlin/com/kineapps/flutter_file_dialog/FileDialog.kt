// Copyright (c) 2020 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

package com.kineapps.flutter_file_dialog

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.OpenableColumns
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.util.UUID
import java.util.concurrent.atomic.AtomicInteger

private const val LOG_TAG = "FileDialog"

// request codes are allocated per dialog launch (see nextRequestCode) so a
// stale or re-delivered activity result from an earlier launch cannot be
// matched to a newer launch's pending result (codes wrap only after
// REQUEST_CODE_RANGE launches, and must stay below the 0xFFFF Android limit)
private const val REQUEST_CODE_BASE = 19110
private const val REQUEST_CODE_RANGE = 40000

// https://developer.android.com/guide/topics/providers/document-provider
// https://developer.android.com/reference/android/content/Intent.html#ACTION_CREATE_DOCUMENT
// https://android.googlesource.com/platform/development/+/master/samples/ApiDemos/src/com/example/android/apis/content/DocumentsSample.java
class FileDialog(
        private var activity: Activity?
) : PluginRegistry.ActivityResultListener {

    companion object {
        private val requestCodeCounter = AtomicInteger(0)

        private fun nextRequestCode(): Int =
                REQUEST_CODE_BASE + Math.floorMod(requestCodeCounter.getAndIncrement(), REQUEST_CODE_RANGE)
    }

    private enum class DialogOperation { PICK_DIRECTORY, PICK_FILE, SAVE_FILE }

    private class PendingDialog(
            val operation: DialogOperation,
            val result: MethodChannel.Result,
            val requestCode: Int
    )

    private var pendingDialog: PendingDialog? = null

    // request code of the currently pending dialog launch, -1 if none
    internal val pendingRequestCode: Int
        get() = synchronized(resultLock) { pendingDialog?.requestCode ?: -1 }
    private var fileExtensionsFilter: Array<String>? = null
    private var copyPickedFileToCacheDir: Boolean = true

    // file to be saved
    private var sourceFile: File? = null
    private var isSourceFileTemp: Boolean = false

    // lock for thread-safe access to pendingResult
    private val resultLock = Any()

    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    fun pickDirectory(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            result.error(
                    "minimum_target",
                    "pickDirectory() available only on Android 21 and above",
                    ""
            )
            return
        }

        if (activity == null) {
            result.error(
                "internal_error",
                "No activity is available",
                "")
            return
        }

        Log.d(LOG_TAG, "pickDirectory - IN")

        val requestCode = setPendingDialog(DialogOperation.PICK_DIRECTORY, result)
        if (requestCode == null) {
            finishWithAlreadyActiveError(result)
            return
        }

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        activity?.startActivityForResult(intent, requestCode)

        Log.d(LOG_TAG, "pickDirectory - OUT")
    }

    fun isPickDirectorySupported(result: MethodChannel.Result) {
        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
    }

    fun pickFile(result: MethodChannel.Result,
                 fileExtensionsFilter: Array<String>?,
                 mimeTypesFilter: Array<String>?,
                 localOnly: Boolean,
                 copyFileToCacheDir: Boolean
    ) {
        Log.d(LOG_TAG, "pickFile - IN, fileExtensionsFilter=$fileExtensionsFilter, mimeTypesFilter=$mimeTypesFilter, localOnly=$localOnly, copyFileToCacheDir=$copyFileToCacheDir")

        if (activity == null) {
            result.error(
                "internal_error",
                "No activity is available",
                "")
            return
        }

        val requestCode = setPendingDialog(DialogOperation.PICK_FILE, result)
        if (requestCode == null) {
            finishWithAlreadyActiveError(result)
            return
        }

        this.fileExtensionsFilter = fileExtensionsFilter
        this.copyPickedFileToCacheDir = copyFileToCacheDir

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            if (localOnly) {
                putExtra(Intent.EXTRA_LOCAL_ONLY, true)
            }
            applyMimeTypesFilterToIntent(mimeTypesFilter, this)
        }

        activity?.startActivityForResult(intent, requestCode)

        Log.d(LOG_TAG, "pickFile - OUT")
    }

    fun saveFile(result: MethodChannel.Result,
                 sourceFilePath: String?,
                 data: ByteArray?,
                 fileName: String?,
                 mimeTypesFilter: Array<String>?,
                 localOnly: Boolean
    ) {
        Log.d(LOG_TAG, "saveFile - IN, sourceFilePath=$sourceFilePath, " +
                "data=${data?.size} bytes, fileName=$fileName, " +
                "mimeTypesFilter=$mimeTypesFilter, localOnly=$localOnly")

        if (activity == null) {
            result.error(
                "internal_error",
                "No activity is available",
                "")
            return
        }

        if (sourceFilePath == null && (fileName == null || data == null)) {
            result.error(
                "invalid_arguments",
                "Missing 'fileName' or 'data'",
                null)
            return
        }

        val requestCode = setPendingDialog(DialogOperation.SAVE_FILE, result)
        if (requestCode == null) {
            finishWithAlreadyActiveError(result)
            return
        }

        if (sourceFilePath != null) {
            isSourceFileTemp = false
            // get source file
            sourceFile = File(sourceFilePath)
            if (!sourceFile!!.exists()) {
                finishWithError(
                        "file_not_found",
                        "Source file is missing",
                        sourceFilePath)
                return
            }
        } else {
            // write data to a temporary file; on failure delete the partial
            // file and release the pending-dialog slot so later calls do not
            // get already_active
            isSourceFileTemp = true
            var tempFile: File? = null
            try {
                tempFile = File.createTempFile(fileName!!, "")
                tempFile.writeBytes(data!!)
                sourceFile = tempFile
            } catch (e: Exception) {
                Log.e(LOG_TAG, "saveFile - creating temporary file failed", e)
                tempFile?.delete()
                finishWithError("save_file_failed", e.localizedMessage, e.toString())
                return
            }
        }

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT)
        intent.addCategory(Intent.CATEGORY_OPENABLE)
        intent.putExtra(Intent.EXTRA_TITLE, fileName ?: sourceFile!!.name)
        if (localOnly) {
            intent.putExtra(Intent.EXTRA_LOCAL_ONLY, true)
        }
        applyMimeTypesFilterToIntent(mimeTypesFilter, intent)

        activity?.startActivityForResult(intent, requestCode)

        Log.d(LOG_TAG, "saveFile - OUT")
    }

    private fun applyMimeTypesFilterToIntent(mimeTypesFilter: Array<String>?, intent: Intent) {
        if (mimeTypesFilter != null) {
            if (mimeTypesFilter.size == 1) {
                intent.type = mimeTypesFilter.first()
            } else {
                intent.type = "*/*"
                intent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypesFilter)
            }
        } else {
            intent.type = "*/*"
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        // take ownership of the pending result here so a slow post-dialog step
        // can never block or complete a later dialog's result; consume it only
        // when the request code matches the pending launch, so a re-delivered
        // result from an earlier launch can never complete a newer dialog's
        // pending result
        val pending: PendingDialog
        synchronized(resultLock) {
            val current = pendingDialog
            if (current == null || current.requestCode != requestCode) {
                return false
            }
            pendingDialog = null
            pending = current
        }
        val result = pending.result
        when (pending.operation) {
            DialogOperation.PICK_DIRECTORY -> {
                if (resultCode == Activity.RESULT_OK && data?.data != null) {
                    val sourceFileUri = data.data
                    Log.d(LOG_TAG, "Picked directory: $sourceFileUri")
                    result.success(sourceFileUri!!.toString())
                } else {
                    Log.d(LOG_TAG, "Cancelled")
                    result.success(null)
                }
                return true
            }
            DialogOperation.PICK_FILE -> {
                val activity = this.activity
                if (activity == null) {
                    result.error(
                        "internal_error",
                        "No activity is available",
                        "")
                    return true
                }
                if (resultCode == Activity.RESULT_OK && data?.data != null) {
                    val sourceFileUri = data.data
                    Log.d(LOG_TAG, "Picked file: $sourceFileUri")
                    val destinationFileName = getFileNameFromPickedDocumentUri(sourceFileUri)
                    if (destinationFileName != null && validateFileExtension(destinationFileName)) {
                        if (copyPickedFileToCacheDir) {
                            copyFileToCacheDirOnBackground(
                                    context = activity,
                                    sourceFileUri = sourceFileUri!!,
                                    destinationFileName = destinationFileName,
                                    result = result)
                        } else {
                            result.success(sourceFileUri!!.toString())
                        }
                    } else {
                        result.error(
                                "invalid_file_extension",
                                "Invalid file type was picked",
                                getFileExtension(destinationFileName))
                    }
                } else {
                    Log.d(LOG_TAG, "Cancelled")
                    result.success(null)
                }
                return true
            }
            DialogOperation.SAVE_FILE -> {
                if (activity == null) {
                    if (isSourceFileTemp) {
                        Log.d(LOG_TAG, "Deleting source file: ${sourceFile?.path}")
                        sourceFile?.delete()
                    }
                    result.error(
                        "internal_error",
                        "No activity is available",
                        "")
                    return true
                }
                if (resultCode == Activity.RESULT_OK && data?.data != null) {
                    val destinationFileUri = data.data
                    saveFileOnBackground(this.sourceFile!!, destinationFileUri!!, isSourceFileTemp, result)
                } else {
                    Log.d(LOG_TAG, "Cancelled")
                    if (isSourceFileTemp) {
                        Log.d(LOG_TAG, "Deleting source file: ${sourceFile?.path}")
                        sourceFile?.delete()
                    }
                    result.success(null)
                }
                return true
            }
        }
    }

    private fun copyFileToCacheDirOnBackground(
            context: Context,
            sourceFileUri: Uri,
            destinationFileName: String,
            result: MethodChannel.Result) {
        val uiScope = CoroutineScope(Dispatchers.Main)
        uiScope.launch {
            try {
                Log.d(LOG_TAG, "Copy on background...")
                val filePath = withContext(Dispatchers.IO) {
                    copyFileToCacheDir(context, sourceFileUri, destinationFileName)
                }
                Log.d(LOG_TAG, "...copied on background, result: $filePath")
                result.success(filePath)
            } catch (e: Exception) {
                Log.e(LOG_TAG, "copyFileToCacheDirOnBackground failed", e)
                result.error("file_copy_failed", e.localizedMessage, e.toString())
            }
        }
    }

    private fun copyFileToCacheDir(
            context: Context,
            sourceFileUri: Uri,
            destinationFileName: String): String {
        // copy to a unique subdirectory of the cache dir (keeping the display
        // file name) so concurrent copies of identically named picked files
        // can never write to the same destination
        val destinationFile = File(
                File(context.cacheDir, "file_dialog-${UUID.randomUUID()}"),
                destinationFileName)
        destinationFile.parentFile?.mkdirs()

        // copy file to cache dir
        Log.d(LOG_TAG, "Copying '$sourceFileUri' to '${destinationFile.path}'")
        var copiedBytes: Long
        context.contentResolver.openInputStream(sourceFileUri).use { inputStream ->
            destinationFile.outputStream().use { outputStream ->
                copiedBytes = inputStream!!.copyTo(outputStream)
            }
        }

        Log.d(LOG_TAG, "Successfully copied file to '${destinationFile.absolutePath}, bytes=$copiedBytes'")

        return destinationFile.absolutePath
    }

    private fun getFileNameFromPickedDocumentUri(uri: Uri?): String? {
        if (uri == null) {
            return null
        }
        var fileName: String? = null
        activity?.contentResolver?.query(uri, null, null, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                fileName = cursor.getString(cursor.getColumnIndexOrThrow(OpenableColumns.DISPLAY_NAME))
            }
        }
        return cleanupFileName(fileName)
    }

    private fun cleanupFileName(fileName: String?): String? {
        // https://stackoverflow.com/questions/2679699/what-characters-allowed-in-file-names-on-android
        return fileName?.replace(Regex("[\\\\/:*?\"<>|\\[\\]]"), "_")
    }

    private fun getFileExtension(fileName: String?): String? {
        return fileName?.substringAfterLast('.', "")
    }

    private fun validateFileExtension(filePath: String): Boolean {
        val validFileExtensions = fileExtensionsFilter
        if (validFileExtensions.isNullOrEmpty()) {
            return true
        }
        val fileExtension = getFileExtension(filePath) ?: return false
        for (extension in validFileExtensions) {
            if (fileExtension.equals(extension, true)) {
                return true
            }
        }
        return false
    }

    private fun saveFileOnBackground(
            sourceFile: File,
            destinationFileUri: Uri,
            isSourceFileTemp: Boolean,
            result: MethodChannel.Result
    ) {
        val uiScope = CoroutineScope(Dispatchers.Main)
        uiScope.launch {
            try {
                Log.d(LOG_TAG, "Saving file on background...")
                val filePath = withContext(Dispatchers.IO) {
                    saveFile(sourceFile, destinationFileUri)
                }
                Log.d(LOG_TAG, "...saved file on background, result: $filePath")
                result.success(filePath)
            } catch (e: SecurityException) {
                Log.e(LOG_TAG, "saveFileOnBackground", e)
                result.error("security_exception", e.localizedMessage, e.toString())
            } catch (e: Exception) {
                Log.e(LOG_TAG, "saveFileOnBackground failed", e)
                result.error("save_file_failed", e.localizedMessage, e.toString())
            } finally {
                if (isSourceFileTemp) {
                    Log.d(LOG_TAG, "Deleting source file: ${sourceFile.path}")
                    sourceFile.delete()
                }
            }
        }
    }

    private fun saveFile(
            sourceFile: File,
            destinationFileUri: Uri
    ): String {
        Log.d(LOG_TAG, "Saving file '${sourceFile.path}' to '${destinationFileUri.path}'")
        sourceFile.inputStream().use { inputStream ->
            activity?.contentResolver?.openOutputStream(destinationFileUri).use { outputStream ->
                outputStream as java.io.FileOutputStream
                outputStream.channel.truncate(0)
                inputStream.copyTo(outputStream)
            }
        }
        Log.d(LOG_TAG, "Saved file to '${destinationFileUri.path}'")
        return destinationFileUri.path!!
    }

    /**
     * Claims the pending-dialog slot for a new launch and returns the request
     * code allocated for it, or null if another dialog is already pending.
     */
    private fun setPendingDialog(operation: DialogOperation, result: MethodChannel.Result): Int? {
        synchronized(resultLock) {
            if (pendingDialog != null) {
                return null
            }
            val requestCode = nextRequestCode()
            // wrap so the result can never be submitted more than once
            pendingDialog = PendingDialog(operation, SingleCompletionResult(result), requestCode)
            return requestCode
        }
    }

    private fun finishWithAlreadyActiveError(result: MethodChannel.Result) {
        Log.w(LOG_TAG, "File dialog is already active")
        result.error("already_active", "File dialog is already active", null)
    }

    private fun takePendingResult(): MethodChannel.Result? {
        synchronized(resultLock) {
            val result = pendingDialog?.result
            pendingDialog = null
            return result
        }
    }

    /**
     * Completes a pending result as cancelled (success(null)). Called by the
     * plugin when this FileDialog is discarded while a dialog result is still
     * pending, so the Dart future resolves instead of hanging forever.
     */
    internal fun cancelPendingResult() {
        val dialog: PendingDialog?
        synchronized(resultLock) {
            dialog = pendingDialog
            pendingDialog = null
        }
        if (dialog == null) {
            return
        }
        Log.w(LOG_TAG, "Cancelling pending result")
        if (dialog.operation == DialogOperation.SAVE_FILE && isSourceFileTemp) {
            Log.d(LOG_TAG, "Deleting source file: ${sourceFile?.path}")
            sourceFile?.delete()
        }
        dialog.result.success(null)
    }

    private fun finishWithError(errorCode: String, errorMessage: String?, errorDetails: String?) {
        takePendingResult()?.error(errorCode, errorMessage, errorDetails)
    }
}
