import json
import os
import re
import sys
from enum import StrEnum
from functools import cached_property
from pathlib import Path
from typing import ClassVar, override

from pydantic import BaseModel, ConfigDict, ValidationError, computed_field


class RulesetLoadFailed(Exception):
    pass


class HookInput(BaseModel):
    session_id: str
    transcript_path: Path
    cwd: Path
    permission_mode: str
    prompt: str

    @classmethod
    def from_stdin(cls):
        return cls.model_validate(json.load(sys.stdin))

    @computed_field
    @property
    def project_dir(self) -> Path | None:
        project_dir_name = os.environ.get("CLAUDE_PROJECT_DIR")
        if project_dir_name is None:
            return None
        return Path(project_dir_name)


class PromptTriggers(BaseModel):
    keywords: list[str] | None
    intent_patterns: list[re.Pattern[str]] | None

    @computed_field
    @cached_property
    def keyword_regex(self) -> re.Pattern[str] | None:
        if self.keywords is None:
            return None
        return re.compile("|".join(self.keywords), flags=re.I)

    def match_keywords(self, prompt: str) -> bool:
        if self.keyword_regex is None:
            return False

        return self.keyword_regex.match(prompt) is not None

    def match_intent(self, prompt: str) -> bool:
        if self.intent_patterns is None:
            return False

        for pattern in self.intent_patterns:
            if re.match(pattern, prompt, flags=re.I) is None:
                continue
            return True
        return False


class SkillType(StrEnum):
    GUARDRAIL = "guardrail"
    DOMAIN = "domain"


class SkillPriority(StrEnum):
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"


class MatchType(StrEnum):
    KEYWORD = "keyword"
    INTENT = "intent"
    NO_MATCH = "none"


class SkillRule(BaseModel):
    model_config: ClassVar[ConfigDict] = ConfigDict(extra="ignore")
    skill_type: SkillType
    priority: SkillPriority
    prompt_triggers: PromptTriggers | None

    def match(self, prompt: str) -> MatchType:
        if self.prompt_triggers is None:
            return MatchType.NO_MATCH

        if self.prompt_triggers.match_keywords(prompt):
            return MatchType.KEYWORD

        if self.prompt_triggers.match_intent(prompt):
            return MatchType.INTENT

        return MatchType.NO_MATCH


class SkillRuleSet(BaseModel):
    version: str
    skills: dict[str, SkillRule]

    @classmethod
    def from_user_home(cls) -> "SkillRuleSet | None":
        """
        Attempts to load a rule set from ~/.claude/skills/skill-rules.json(c).
        """
        user_home = Path.home()
        return cls.from_project_dir(user_home)

    @classmethod
    def from_project_dir(
        cls, project_dir: Path | os.PathLike[str]
    ) -> "SkillRuleSet | None":
        """
        Attempts to load a rule set from the given project.

        Relative path is $PROJECT_ROOT/.claude/skills/skill-rules.json(c)
        """
        file_names = ["skill-rules.json", "skill-rules.jsonc"]
        skills_dir = Path(project_dir) / ".claude" / "skills"
        for name in file_names:
            rule_file = skills_dir / name
            return cls.from_file(rule_file)

    @classmethod
    def from_file(cls, rule_file: Path | os.PathLike[str]) -> "SkillRuleSet | None":
        """
        Attempts to load a `skill-rules.json` file, either user- or project-level.
        """
        if not Path(rule_file).exists():
            return None

        with open(rule_file) as rules_fd:
            return cls.model_validate(json.load(rules_fd))

    def match_rules(self, prompt: str) -> "MatchedSkillSet":
        result = MatchedSkillSet()

        for skill, rule in self.skills.items():
            match_type = rule.match(prompt)
            if match_type == MatchType.NO_MATCH:
                continue
            result.add_match(skill, match_type, rule)

        return result


class MatchedSkill(SkillRule):
    name: str
    match_type: MatchType

    @classmethod
    def from_rule(
        cls, name: str, match_type: MatchType, rule: SkillRule
    ) -> "MatchedSkill":
        assert match_type != MatchType.NO_MATCH, "Cannot use a non-matched skill!"
        model_dict = rule.model_dump()
        model_dict.update(name=name, match_type=match_type)
        return cls.model_validate(model_dict)

    @override
    def __str__(self) -> str:
        return f"{self.name} - {self.skill_type}"


class MatchedSkillSet(BaseModel):
    skills: list[MatchedSkill] = []

    def add_match(self, name: str, match_type: MatchType, rule: SkillRule):
        assert match_type != MatchType.NO_MATCH, "Cannot add a non-matched skill!"
        skill = MatchedSkill.from_rule(name, match_type, rule)
        self.skills.append(skill)

    def _filter_skills(
        self, priority: SkillPriority | None = None, skill_type: SkillType | None = None
    ) -> list[MatchedSkill]:
        result: list[MatchedSkill] = []
        for skill in self.skills:
            if priority is not None and skill.priority != priority:
                continue
            if skill_type is not None and skill.skill_type != skill_type:
                continue
            result.append(skill)
        return result

    @computed_field
    @property
    def critical_skills(self) -> list[MatchedSkill]:
        return self._filter_skills(priority=SkillPriority.CRITICAL)

    @computed_field
    @property
    def recommended_skills(self) -> list[MatchedSkill]:
        return self._filter_skills(priority=SkillPriority.HIGH)

    @computed_field
    @property
    def suggested_skills(self) -> list[MatchedSkill]:
        return self._filter_skills(priority=SkillPriority.MEDIUM)

    @computed_field
    @property
    def optional_skills(self) -> list[MatchedSkill]:
        return self._filter_skills(priority=SkillPriority.LOW)

    def render_skills(self, section_name: str, skills: list[MatchedSkill]) -> str:
        rendered_skills = "\n".join(f"- {skill}" for skill in skills)
        return f"""
        ## {section_name}
        
        {rendered_skills}
        """

    def render(self):
        critical_section = self.render_skills(
            "Critical Skills | REQUIRED", self.critical_skills
        )
        recommended_section = self.render_skills(
            "Recommended Skills", self.recommended_skills
        )
        suggested_section = self.render_skills(
            "Suggested Skills", self.suggested_skills
        )
        optional_section = self.render_skills("Optional Skills", self.optional_skills)

        return f"""
        # SKILL ACTIVATION CHECK
        
        {critical_section}

        {recommended_section}

        {suggested_section}

        {optional_section}

        ACTION: Load skills BEFORE responding.
        """


def main():
    exit_code: int = 0
    try:
        hook_input = HookInput.from_stdin()

        rule_set: SkillRuleSet | None = None
        if hook_input.project_dir is not None:
            rule_set = SkillRuleSet.from_project_dir(hook_input.project_dir)

        if rule_set is None:
            rule_set = SkillRuleSet.from_user_home()

        if rule_set is None:
            raise RulesetLoadFailed()

        matched_skills = rule_set.match_rules(hook_input.prompt)
        print(matched_skills.render())
    except RulesetLoadFailed:
        print("Failed to load rule set. Check if a skill-rules.json file exists.")
        exit_code = 1
    except ValidationError as e:
        print("Validation errors occurred:")
        for error in e.errors():
            print(error)
        exit_code = 2
    except Exception as e:
        print("Unknown error occurred:")
        print(e)
        exit_code = 3
    finally:
        sys.exit(exit_code)


# TODO: Extract this to a dedicated plugin

if __name__ == "__main__":
    main()
