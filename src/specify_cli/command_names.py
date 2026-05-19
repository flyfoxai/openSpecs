"""Command naming helpers for the sp fork.

The upstream extension ecosystem still uses ``speckit.<ext>.<command>``.
Only the built-in workflow commands are renamed to the shorter runtime
prefix: ``sp.<command>`` for file/slash command names and ``sp-<command>``
for skill directories.
"""

from __future__ import annotations

CORE_COMMAND_STEMS = frozenset(
    {
        "analyze",
        "bundle",
        "checklist",
        "clarify",
        "constitution",
        "flow",
        "gate",
        "implement",
        "plan",
        "specify",
        "tasks",
        "taskstoissues",
        "ui",
    }
)


def core_command_stem(command_name: str) -> str | None:
    """Return the built-in command stem if *command_name* names one."""
    name = command_name.strip()
    if name.startswith(("/", "$")):
        name = name[1:]

    for prefix in ("sp.", "speckit."):
        if name.startswith(prefix):
            candidate = name[len(prefix) :]
            return candidate if candidate in CORE_COMMAND_STEMS else None

    for prefix in ("sp-", "speckit-"):
        if name.startswith(prefix):
            candidate = name[len(prefix) :].replace("-", ".")
            return candidate if candidate in CORE_COMMAND_STEMS else None

    return name if name in CORE_COMMAND_STEMS else None


def command_file_name(template_name: str, extension: str = ".md") -> str:
    """Return the on-disk command filename for a template stem."""
    stem = core_command_stem(template_name)
    if stem:
        return f"sp.{stem}{extension}"
    name = template_name
    if name.startswith("sp."):
        name = "speckit." + name[len("sp.") :]
    elif not name.startswith("speckit."):
        name = f"speckit.{name}"
    return f"{name}{extension}"


def command_invocation(command_name: str, separator: str = ".") -> str:
    """Return a slash-command invocation without arguments."""
    stem = core_command_stem(command_name)
    if stem:
        return f"/sp{separator}{stem.replace('.', separator)}"

    name = command_name.strip()
    if name.startswith(("/", "$")):
        name = name[1:]
    if name.startswith("sp."):
        name = "speckit." + name[len("sp.") :]
    elif name.startswith("sp-"):
        name = "speckit-" + name[len("sp-") :]
    elif not name.startswith("speckit."):
        name = f"speckit.{name}"

    if separator == "-":
        if name.startswith("speckit."):
            return "/speckit-" + name[len("speckit.") :].replace(".", "-")
        return "/" + name.replace(".", "-")
    return "/" + name.replace("-", ".") if name.startswith("speckit-") else "/" + name


def skill_directory_name(command_name: str) -> str:
    """Return the skill directory/frontmatter name for a command."""
    stem = core_command_stem(command_name)
    if stem:
        return f"sp-{stem.replace('.', '-')}"

    name = command_name.strip()
    if name.startswith(("/", "$")):
        name = name[1:]
    if name.startswith("sp."):
        name = "speckit." + name[len("sp.") :]
    if name.startswith("speckit."):
        return "speckit-" + name[len("speckit.") :].replace(".", "-")
    if name.startswith("speckit-"):
        return name
    return "speckit-" + name.replace(".", "-")
