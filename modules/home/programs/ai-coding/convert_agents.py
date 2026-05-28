# /// script
# dependencies = [
# "PyYAML",
# ]
# requires-python = ">=3.13"
# ///


import json
from pathlib import Path
from typing import Any, TypedDict

from yaml import safe_dump, safe_load
from copy import deepcopy


HOME_MANAGER_DIR = Path(__file__).parent.parent.parent

PROGRAMS_DIR = HOME_MANAGER_DIR / "programs"

AI_CODING_DIR = PROGRAMS_DIR / "ai-coding"
CLAUDE_DIR = PROGRAMS_DIR / "claude"

OPENCODE_DIR = PROGRAMS_DIR / "opencode"


class AgentConfig(TypedDict):
    frontmatter_claude: str
    frontmatter_opencode: str
    content: str


model_mappings = {
    "haiku": "github-copilot/claude-haiku-4.5",
    "sonnet": "github-copilot/claude-sonnet-4.6",
    "opus": "github-copilot/claude-opus-4.6",
}


agents: dict[str, AgentConfig] = dict()

for agent in (AI_CODING_DIR / "agents").iterdir():
    ref_file = agent / "reference.md"
    full = ref_file.open().read()
    sections = full.split("---")
    _, frontmatter_raw, prompt = sections
    frontmatter_claude: dict[str, Any] = safe_load(frontmatter_raw)
    frontmatter_opencode = deepcopy(frontmatter_claude)
    frontmatter_opencode["model"] = model_mappings[frontmatter_claude["model"]]
    del frontmatter_opencode["tools"]

    agents[agent.stem] = {
        "reference": full.strip(),
        "content": prompt.strip(),
        "frontmatter_claude": frontmatter_claude,
        "frontmatter_opencode": frontmatter_opencode,
    }


for name, agent in agents.items():
    agent_dir = AI_CODING_DIR / "agents" / name
    if not agent_dir.exists():
        agent_dir.mkdir()
    with (
        open(agent_dir / "reference.md", "w+") as reference_file,
        open(agent_dir / "agent.md", "w+") as agent_file,
        open(agent_dir / "claude-config.yml", "w+") as claude_config_file,
        open(agent_dir / "opencode-config.json", "w+") as opencode_config_file,
    ):
        reference_file.write(agent["reference"])
        agent_file.write(agent["content"])

        safe_dump(agent["frontmatter_claude"], claude_config_file)
        json.dump(agent["frontmatter_opencode"], opencode_config_file)
