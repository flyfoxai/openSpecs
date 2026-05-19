"""Expected file helpers for the sp command inventory."""

from __future__ import annotations

from pathlib import Path

from specify_cli.command_names import command_file_name, skill_directory_name


REPO_ROOT = Path(__file__).resolve().parents[2]
COMMAND_TEMPLATE_ROOT = REPO_ROOT / "templates" / "commands"
PROJECT_TEMPLATE_ROOT = REPO_ROOT / "templates" / "project"


def command_stems() -> list[str]:
    return sorted(path.stem for path in COMMAND_TEMPLATE_ROOT.glob("*.md"))


def command_files(command_dir: str, extension: str) -> list[str]:
    return [
        f"{command_dir}/{command_file_name(stem, extension)}"
        for stem in command_stems()
    ]


def skill_files(skills_dir: str) -> list[str]:
    return [
        f"{skills_dir}/{skill_directory_name(stem)}/SKILL.md"
        for stem in command_stems()
    ]


def project_scaffold_files() -> list[str]:
    if not PROJECT_TEMPLATE_ROOT.is_dir():
        return []
    return sorted(
        path.relative_to(PROJECT_TEMPLATE_ROOT).as_posix()
        for path in PROJECT_TEMPLATE_ROOT.rglob("*")
        if path.is_file()
    )
