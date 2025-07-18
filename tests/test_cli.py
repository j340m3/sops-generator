"""This module provides tests for CLI module."""

# ruff: noqa: S101

from click.testing import CliRunner

from sops_generator import __version__
from sops_generator.cli import main


def test_cli() -> None:
    """Test the CLI program."""
    runner = CliRunner()
    result = runner.invoke(main, ["--name", "test", "--count", "1"])
    assert result.exit_code == 0
    assert result.output.startswith(
        f"Hello test! I am sops_generator v{__version__}.\n"
    )
