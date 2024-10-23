#!/usr/bin/env python3
import argparse
from pathlib import Path
import sys

from packaging.tags import Tag
from packaging.utils import parse_wheel_filename
import platform


def diagnose_unsupported(p: Path) -> str:
    p = Path(p)
    if not p.exists():
        return f"File '{p}' does not exist"
    if not p.is_file():
        return f"'{p}' is not a file"
    if p.suffix != ".whl":
        return f"'{p}' has incorrect suffix; the suffix must be .whl"

    # The wheel filename must parse:
    tags: frozenset[Tag]
    name, ver, build,  tags = parse_wheel_filename(p.name)

    print(f"Name: {name}")
    print(f"Version: {ver}")
    print(f"Build: {build}")

    print("Tags:")
    tag = None
    for t in tags:
        print(t.abi, t.interpreter, t.platform)
        tag = t
    print("End of tags")

    # Is a debug wheel being loaded in a non-debug interpreter?
    if tag.abi.endswith("d"):
        if not sys.flags.debug:
            return f"The ABI of the wheel is {tag.abi}, which is a debug wheel. However, the python interpreter does not have the debug flags set."
    # Is a cpython wheel being loaded by a non-cpython interpreter?
    if tag.abi.startswith("cp"):
        if sys.implementation.name != "cpython":
            return f"The ABI of the wheel '{p}' requires cpython, but the system implementation is {sys.implementation.name}"

    # If the interpreter is version intolerant, what interpreter should it be using?
    idx = tag.interpreter.find("3")
    if 0 <= idx < len(tag.interpreter) - 1:
        # Iterate over the string starting from the next index
        input_string = tag.interpreter[idx + 1:]
        print(f"input_string: {input_string}")
        index = 0
        result = ""
        while index < len(input_string) and input_string[index].isdigit():
            result += input_string[index]
            index += 1
        print(f"result: {result}")
        supported_minor = int(result)
        print(f"Supported minor version: {supported_minor} and current minor version: {sys.version_info.minor}")
        if sys.version_info.minor != supported_minor:
            return f"The python minor version is {sys.version_info.minor}, but the wheel only supports minor version {supported_minor}"

    # There should be no restriction on the platform:
    if tag.platform == "any":
        return ""
    pieces = tag.platform.split("_")
    if len(pieces) != 4:
        print("Unable to parse the platform tag")

    wheel_os_name = pieces[0]
    wheel_os_version_major = pieces[1]
    wheel_os_version_minor = pieces[2]
    cpu_architecture = pieces[3]
    if wheel_os_name == "macosx":
        if sys.platform != "darwin":
            return f"The wheel was build for macosx, but the current platform is {sys.platform}"

    if cpu_architecture != platform.machine():
        return f"The CPU architecture supported by the wheel is {cpu_architecture}, but the platform has architecture {platform.machine()}"

    print(f"platform.mac_ver()= {platform.mac_ver()}")
    if platform.mac_ver()[0] != "":
        os_major, os_minor, os_patch = platform.mac_ver()[0].split(".")
        if int(os_major) < int(wheel_os_version_major):
            return f"The operating system major version is {os_major}, but the wheel requires at least OS major version {wheel_os_version_major}"
        if int(os_major) == int(wheel_os_version_major):
            if int(os_minor) < int(wheel_os_version_minor):
                return f"The operating system minor version is {os_minor}, but the wheel requires at least OS major version {wheel_os_version_minor}"

    return ""


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Diagnoses why a wheel is unsupported on a particular platform."
    )
    parser.add_argument("wheelfile", type=Path, help="The name of the wheel file.")
    args = parser.parse_args()
    error_msg = diagnose_unsupported(args.wheelfile)
    if len(error_msg) > 0:
        print(
            f"ERROR: {args.wheelfile} is not supported on this platform. Reason: {error_msg}"
        )
    else:
        print(f"{args.wheelfile} should be supported on your platform!")
