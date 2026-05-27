# /// script
# dependencies = [
# "PyYAML",
# ]
# requires-python = ">=3.13"
# ///


from pathlib import Path
from typing import TypedDict

from yaml import safe_load


HOME_MANAGER_DIR = Path(__file__).parent.parent.parent

PROGRAMS_DIR = HOME_MANAGER_DIR / "programs"

AI_CODING_DIR = PROGRAMS_DIR / "ai-coding"
CLAUDE_DIR = PROGRAMS_DIR / "claude"

OPENCODE_DIR = PROGRAMS_DIR / "opencode"

agents = dict()

# claude tools


class ToolMapping(TypedDict):
    claude: str
    opencode: str


tool_mappings = {
    "bash": {"Bash", "bash"},
    "edit": {"Edit", "edit"},
    "question": {"AskUserQuestion", "question"},
}

for agent in (CLAUDE_DIR / "agents").iterdir():
    frontmatter_raw = agent.open().read().split("---")[1].strip()
    frontmatter = safe_load(frontmatter_raw)
    agents[agent.name] = frontmatter

print(agents)
