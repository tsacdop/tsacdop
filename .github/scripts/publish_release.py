"""Publish signed CI artifacts for an existing release tag; never rebuild them."""

import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile


def output(*args):
    return subprocess.check_output(args, text=True).strip()


def gh(*args):
    return output("gh", *args, "--repo", os.environ["GITHUB_REPOSITORY"])


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def certificate_digests(result):
    # Signer labels vary between Android build-tools versions.
    digests = re.findall(r"certificate SHA-256 digest:\s*([0-9a-f]{64})(?=\s|$)",
                         result, re.IGNORECASE)
    require(digests, f"APK signing certificate is missing from apksigner output:\n{result}")
    return frozenset(digest.lower() for digest in digests)


def main():
    repo = os.environ["GITHUB_REPOSITORY"]
    tag = os.environ["RELEASE_TAG"]
    run_id = os.environ["BUILD_RUN_ID"]
    require(re.fullmatch(r"v\d+\.\d+\.\d+", tag), "Expected a stable vX.Y.Z tag")
    require(run_id.isdecimal(), "Expected a numeric build run ID")
    commit = output("git", "rev-parse", f"{tag}^{{commit}}")
    run = json.loads(output("gh", "api", f"repos/{repo}/actions/runs/{run_id}"))
    require(run["head_sha"] == commit, "Build commit does not match the release tag")
    require(run["status"] == "completed" and run["conclusion"] == "success",
            "Build must complete successfully before publication")
    require(run["event"] == "push" and run["head_branch"] == "main"
            and run["path"] == ".github/workflows/flutter_build.yml",
            "Expected the main branch Flutter Build workflow")
    pubspec = output("git", "show", f"{tag}:pubspec.yaml")
    version = re.search(r"^version: (\d+\.\d+\.\d+)\+(\d+)$", pubspec, re.MULTILINE)
    require(version is not None and f"v{version[1]}" == tag,
            "Tag does not match pubspec version")
    base_code = int(version[2])

    directory = Path(tempfile.mkdtemp(prefix="tsacdop-release-"))
    gh("run", "download", run_id, "--name", "release-file", "--dir", str(directory / "build"))
    apks = sorted((directory / "build").rglob("*-github-release.apk"))
    abi_codes = {"armeabi-v7a": 1, "arm64-v8a": 2, "x86_64": 3}
    expected = {f"app-{abi}-github-release.apk" for abi in abi_codes}
    require(len(apks) == 3 and {apk.name for apk in apks} == expected,
            "Expected exactly three signed GitHub APKs")

    sdk = Path(os.environ["ANDROID_HOME"]) / "build-tools"
    tools = [p for p in sdk.iterdir() if re.fullmatch(r"\d+(\.\d+)+", p.name)
             and (p / "apksigner").exists() and (p / "aapt").exists()]
    require(tools, "Android build tools are unavailable")
    tool = max(tools, key=lambda p: tuple(map(int, p.name.split("."))))

    def certificate(apk):
        result = output(str(tool / "apksigner"), "verify", "--print-certs", str(apk))
        return certificate_digests(result)

    previous = json.loads(gh("release", "view", "--json", "tagName"))["tagName"]
    gh("release", "download", previous, "--pattern", "*arm64-v8a*-release.apk",
       "--dir", str(directory / "previous"))
    previous_apks = list((directory / "previous").glob("*.apk"))
    require(len(previous_apks) == 1, "Expected one previous arm64 APK")
    previous_certificate = certificate(previous_apks[0])
    checksums = {}
    for apk in apks:
        abi = apk.name.removeprefix("app-").removesuffix("-github-release.apk")
        badging = output(str(tool / "aapt"), "dump", "badging", str(apk))
        require("name='com.stonegate.tsacdop'" in badging, "Incorrect application ID")
        require(f"versionName='{version[1]}'" in badging, "Incorrect APK version name")
        require(f"versionCode='{base_code * 10 + abi_codes[abi]}'" in badging,
                "Incorrect APK version code")
        require(certificate(apk) == previous_certificate,
                "APK certificate differs from the previous GitHub release")
        checksums[apk.name] = hashlib.sha256(apk.read_bytes()).hexdigest()
        print(f"Verified {apk.name}: {version[1]}, signing certificate matches", flush=True)

    sums = directory / "SHA256SUMS.txt"
    sums.write_text("".join(f"{digest}  {name}\n" for name, digest in checksums.items()))
    checksums[sums.name] = hashlib.sha256(sums.read_bytes()).hexdigest()
    changelog = output("git", "show", f"{tag}:CHANGELOG.md")
    section = re.search(rf"^## {re.escape(version[1])}\s*\n(.*?)(?=^## |\Z)",
                        changelog, re.MULTILINE | re.DOTALL)
    require(section is not None, "Release notes are missing from CHANGELOG.md")
    notes = directory / "notes.md"
    notes.write_text(section[1].strip() + "\n\n"
                     "The attached APKs are signed GitHub builds. Choose arm64-v8a for most "
                     "current Android phones, armeabi-v7a for 32-bit ARM devices, or x86_64 "
                     "for Intel/AMD devices and emulators.\n\n"
                     f"**Full changelog:** https://github.com/{repo}/compare/{previous}...{tag}\n")
    files = [*apks, sums]
    existing = subprocess.run(["gh", "release", "view", tag, "--repo", repo,
                               "--json", "isDraft"], capture_output=True, text=True)
    if existing.returncode == 0:
        require(json.loads(existing.stdout)["isDraft"], "Release is already published")
        gh("release", "edit", tag, "--title", tag, "--notes-file", str(notes))
        gh("release", "upload", tag, *map(str, files), "--clobber")
    else:
        gh("release", "create", tag, *map(str, files), "--draft", "--verify-tag",
           "--title", tag, "--notes-file", str(notes))
    release = json.loads(gh("release", "view", tag, "--json", "assets"))
    uploaded = {asset["name"]: asset for asset in release["assets"]}
    require(set(uploaded) == set(checksums), "Release assets do not match verified files")
    for file in files:
        asset = uploaded[file.name]
        require(asset["size"] == file.stat().st_size, "Uploaded asset size mismatch")
        require(asset.get("digest") == f"sha256:{checksums[file.name]}",
                "Uploaded asset checksum mismatch")
    remote_commit = json.loads(output("gh", "api", f"repos/{repo}/commits/{tag}"))["sha"]
    require(remote_commit == commit, "Remote tag changed during publication")
    gh("release", "edit", tag, "--draft=false", "--latest")
    print(gh("release", "view", tag, "--json", "url", "--jq", ".url"), flush=True)


if __name__ == "__main__":
    main()
