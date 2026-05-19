"""Lingma IDE integration. — skills-based agent.

Lingma IDE installs skills under ``.lingma/skills/``. The directory
name is resolved by ``skill_directory_name()``: built-in commands use
``sp-<name>/SKILL.md`` and extension/preset commands use
``speckit-<extension>-<name>/SKILL.md``. In Specify CLI, the Lingma
integration is skills-only, and ``--skills`` defaults to ``True``.
"""

from __future__ import annotations

from ..base import IntegrationOption, SkillsIntegration


class LingmaIntegration(SkillsIntegration):
    """Integration for Lingma IDE."""

    key = "lingma"
    config = {
        "name": "Lingma",
        "folder": ".lingma/",
        "commands_subdir": "skills",
        "install_url": None,
        "requires_cli": False,
    }
    registrar_config = {
        "dir": ".lingma/skills",
        "format": "markdown",
        "args": "$ARGUMENTS",
        "extension": "/SKILL.md",
    }
    context_file = ".lingma/rules/specify-rules.md"

    @classmethod
    def options(cls) -> list[IntegrationOption]:
        return [
            IntegrationOption(
                "--skills",
                is_flag=True,
                default=True,
                help="Install as agent skills",
            ),
        ]
