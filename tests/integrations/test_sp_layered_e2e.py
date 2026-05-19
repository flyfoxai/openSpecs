"""End-to-end checks for the SP layered workflow packaging."""

from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path

from typer.testing import CliRunner

from specify_cli import app


def _files_containing(root: Path, needle: str) -> list[Path]:
    matches = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        try:
            if needle in path.read_text(encoding="utf-8"):
                matches.append(path)
        except UnicodeDecodeError:
            continue
    return matches


def _init_project(tmp_path: Path, integration: str) -> Path:
    project = tmp_path / f"sp-layered-{integration}"
    runner = CliRunner()
    old_cwd = os.getcwd()
    try:
        os.chdir(tmp_path)
        result = runner.invoke(
            app,
            [
                "init",
                str(project),
                "--offline",
                "--integration",
                integration,
                "--script",
                "sh",
                "--no-git",
                "--ignore-agent-tools",
            ],
            catch_exceptions=False,
        )
    finally:
        os.chdir(old_cwd)

    assert result.exit_code == 0, result.output
    return project


def test_sp_layered_feature_scaffold_and_command_rendering(tmp_path: Path):
    codex_project = _init_project(tmp_path, "codex")
    copilot_project = _init_project(tmp_path, "copilot")

    fresh_prereq = subprocess.run(
        ["bash", ".specify/scripts/bash/check-prerequisites.sh", "--json"],
        cwd=codex_project,
        check=True,
        text=True,
        capture_output=True,
    )
    fresh_payload = json.loads(fresh_prereq.stdout)
    assert fresh_payload["branch"]
    assert fresh_payload["hasActiveFeature"] is False
    assert fresh_payload["activeFeature"] == ""
    assert fresh_payload["featureDir"] == ""
    for key in ("FEATURE_DIR", "FEATURE_SPEC", "BUNDLE", "IMPL_PLAN", "TASKS"):
        assert fresh_payload[key] == ""

    fresh_paths_only = subprocess.run(
        [
            "bash",
            ".specify/scripts/bash/check-prerequisites.sh",
            "--json",
            "--paths-only",
        ],
        cwd=codex_project,
        check=True,
        text=True,
        capture_output=True,
    )
    fresh_paths_payload = json.loads(fresh_paths_only.stdout)
    assert fresh_paths_payload["hasActiveFeature"] is False
    assert fresh_paths_payload["featureDir"] == ""
    for key in ("FEATURE_DIR", "FEATURE_SPEC", "BUNDLE", "IMPL_PLAN", "TASKS"):
        assert fresh_paths_payload[key] == ""

    fresh_require_plan = subprocess.run(
        ["bash", ".specify/scripts/bash/check-prerequisites.sh", "--json", "--require-plan"],
        cwd=codex_project,
        text=True,
        capture_output=True,
    )
    assert fresh_require_plan.returncode == 1
    fresh_require_payload = json.loads(fresh_require_plan.stdout)
    assert fresh_require_payload["hasActiveFeature"] is False
    assert fresh_require_payload["missing"] == ["no_active_feature"]
    assert fresh_require_payload["MISSING"] == ["no_active_feature"]
    assert "no_active_feature" in fresh_require_plan.stderr

    create_result = subprocess.run(
        [
            "bash",
            ".specify/scripts/bash/create-new-feature.sh",
            "--json",
            "--short-name",
            "demo",
            "Demo feature",
        ],
        cwd=codex_project,
        check=True,
        text=True,
        capture_output=True,
    )
    payload = json.loads(create_result.stdout)
    assert payload["BRANCH_NAME"] == "001-demo"

    feature_dir = codex_project / "specs" / "001-demo"
    expected_files = [
        "spec.md",
        "memory/index.md",
        "memory/stable-context.md",
        "memory/open-items.md",
        "memory/trace-index.md",
        "memory/worksets/index.md",
        "flows/index.md",
        "ui/index.md",
        "delivery/01-prd.md",
        "analysis.md",
        "bundle.md",
        "gate.md",
        "tasks.md",
    ]
    for rel_path in expected_files:
        assert (feature_dir / rel_path).exists(), f"missing scaffold file: {rel_path}"

    placeholder_leaks = _files_containing(feature_dir, "__FEATURE_")
    assert not placeholder_leaks, f"unreplaced feature placeholders: {placeholder_leaks}"

    active_context = (codex_project / ".specify/memory/active-context.md").read_text(
        encoding="utf-8"
    )
    project_index = (codex_project / ".specify/memory/project-index.md").read_text(
        encoding="utf-8"
    )
    feature_map = (codex_project / ".specify/memory/feature-map.md").read_text(
        encoding="utf-8"
    )
    assert "| Active Feature | 001-demo |" in active_context
    assert "| Active Feature | 001-demo |" in project_index
    assert "| 001-demo |" in feature_map

    no_require = subprocess.run(
        ["bash", ".specify/scripts/bash/check-prerequisites.sh", "--json"],
        cwd=codex_project,
        check=True,
        text=True,
        capture_output=True,
    )
    no_require_payload = json.loads(no_require.stdout)
    assert no_require_payload["hasActiveFeature"] is True
    assert no_require_payload["activeFeature"] == "001-demo"
    assert "plan.md" not in no_require_payload["missing"]

    require_plan = subprocess.run(
        ["bash", ".specify/scripts/bash/check-prerequisites.sh", "--json", "--require-plan"],
        cwd=codex_project,
        text=True,
        capture_output=True,
    )
    assert require_plan.returncode == 1
    require_plan_payload = json.loads(require_plan.stdout)
    assert "plan.md" in require_plan_payload["missing"]

    codex_plan = (
        codex_project / ".agents/skills/sp-plan/SKILL.md"
    ).read_text(encoding="utf-8")
    assert "Suggest `/sp-tasks`." in codex_plan
    assert "__SPECKIT_COMMAND_" not in codex_plan

    copilot_plan = (
        copilot_project / ".github/agents/sp.plan.agent.md"
    ).read_text(encoding="utf-8")
    assert "agent_scripts" not in copilot_plan
    assert "Suggest `/sp.tasks`." in copilot_plan
    assert "__SPECKIT_COMMAND_" not in copilot_plan

    assert not (codex_project / "scripts").exists()
