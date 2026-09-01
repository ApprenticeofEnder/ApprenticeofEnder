#!/usr/bin/env python

import glob
import json
import re
import shlex
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any


def extract_file_path() -> Path:
    agent_input: dict[str, Any] = json.load(sys.stdin)
    file_path: str = agent_input["tool_input"]["file_path"]
    return Path(file_path).resolve()


@dataclass
class ProcessorResult:
    result: str
    return_code: int = 0


class FileProcessor:
    command: str
    matchers: list[str] | None = None
    args: list[str] | None = None

    def process(self, file_path: Path) -> ProcessorResult:
        def substitute_file(arg: str) -> str:
            if arg == "FILE":
                return file_path.resolve().as_posix()

            return arg

        if self.args is None:
            self.args = [file_path.resolve().as_posix()]
        else:
            self.args = list(map(substitute_file, self.args))

        full_command = shlex.join([self.command] + self.args)

        print("Running", full_command)

        try:
            result: str = subprocess.check_output(
                full_command, shell=True, executable="/bin/bash"
            ).decode()
            return ProcessorResult(result=result)
        except subprocess.CalledProcessError as cpe:
            result = cpe.output
            return_code = cpe.returncode
            return ProcessorResult(result=result, return_code=return_code)

    def run(self, file_path: Path) -> ProcessorResult | None:
        if self.matchers is None:
            return self.process(file_path)

        resolved_path = file_path.resolve().as_posix()

        file_regexes = [
            re.compile(
                glob.translate(matcher, recursive=True, include_hidden=True)
            )
            for matcher in self.matchers
        ]

        for file_regex in file_regexes:
            regex_match = file_regex.match(resolved_path)
            if regex_match is None:
                continue

            return self.process(file_path)

        return None


class PrettierProcessor(FileProcessor):
    matchers = [
        # keep-sorted start
        "**/*.css",
        "**/*.html",
        "**/*.js",
        "**/*.jsx",
        "**/*.md",
        "**/*.ts",
        "**/*.tsx",
        "**/*.vue",
        "**/*.yaml",
        # keep-sorted end
    ]
    command = "bunx"
    args = ["prettier", "--write", "FILE"]


class RuffFormatProcessor(FileProcessor):
    matchers = ["**/*.py"]
    command = "ruff"
    args = ["format", "FILE"]


class RuffCheckProcessor(FileProcessor):
    matchers = ["**/*.py"]
    command = "ruff"
    args = ["check", "FILE"]


def main():
    file_path: Path = extract_file_path()
    processors: list[FileProcessor] = [PrettierProcessor()]
    for processor in processors:
        result = processor.run(file_path)

        if result is None:
            continue

        if result.return_code == 0:
            continue

        print(result.result, file=sys.stderr)
        sys.exit(result.return_code)


main()
