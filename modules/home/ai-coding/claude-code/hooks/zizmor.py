#!/usr/bin/env python

import json
import shlex
import subprocess
import sys
import textwrap

file_path = json.load(sys.stdin)["tool_input"]["file_path"]

full_command = shlex.join(["zizmor", "--format", "json", file_path])

zizmor_result = subprocess.run(
    full_command, shell=True, executable="/bin/bash", capture_output=True
)

zizmor_output = json.loads(zizmor_result.stdout)

if len(zizmor_output) == 0:
    print("Zizmor reports no findings. File is clear.")
    sys.exit(0)

rendered_findings = []

print(f"Zizmor has findings in {file_path}.\n")

for finding in zizmor_output:
    locations: list[str] = []
    for location in finding["locations"]:
        filename = location["symbolic"]["key"]["Local"]["verbatim_path"]
        start = location["concrete"]["location"]["start_point"]
        end = location["concrete"]["location"]["end_point"]
        locations.append(
            f"{filename}@{start['row']}:{start['column']}-{end['row']}:{end['column']}"
        )
    rendered_locations = "\n".join(f"- {location}" for location in locations)
    rendered = (
        textwrap.dedent(
            f"""
            Finding: {finding["ident"]}
            Description: {finding["desc"]}
            Url: {finding["url"]}
            Confidence: {finding["determinations"]["confidence"]}
            Severity: {finding["determinations"]["severity"]}
            Locations:
            """
        ).lstrip()
        + rendered_locations
    )
    print(rendered)
    print("---")
