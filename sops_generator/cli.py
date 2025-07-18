"""This module provides the CLI functionality for our package."""

import click
from sopsy import Sopsy

from sops_generator import __version__
from sops_generator.resources import read_help_text


@click.command()
@click.option("--name", prompt="Your name", help="The person to greet.")
@click.option(
    "--path", prompt="Path to NixConfig", help="Path to the NixOS config file"
)
@click.option("--count", default=1, help="Number of greetings.")
@click.version_option(__version__, prog_name="sops_generator")
def main(name: str, path: str, count: int) -> None:
    """Run the CLI program."""
    for _ in range(count):
        click.secho(f"Hello {name}! I am sops_generator v{__version__}.", bold=True)
    sops = Sopsy(path)
    click.secho(sops.get("my_secret_key"))
    click.echo()

    click.secho(read_help_text(), fg="yellow")
