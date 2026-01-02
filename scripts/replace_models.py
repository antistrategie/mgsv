"""
This script replaces target models in the mod/ folder with source models from exports/,
renaming them to match the target filenames.
"""

from __future__ import annotations

import shutil
from pathlib import Path
from typing import Optional

# Configuration: source model -> target model to replace
# The key is the model in exports/ folder
# The value is the model name to find and replace in mod/ folder
MODEL_REPLACEMENTS = {
    "leva0_body.fmdl": "sna0_main0_def.fmdl",
    "leva0_head.fmdl": "sna0_face0_cov.fmdl",
}

# Paths relative to script location
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
EXPORTS_DIR = PROJECT_ROOT / "exports"
MOD_DIR = PROJECT_ROOT / "mod"


def find_source_model(source_name: str) -> Optional[Path]:
    """Find a source model in the exports directory."""
    source_path = EXPORTS_DIR / source_name
    if source_path.exists():
        return source_path

    # Also search recursively in case models are in subdirectories
    for path in EXPORTS_DIR.rglob(source_name):
        return path

    return None


def find_target_models(target_name: str) -> list[Path]:
    """Find all instances of a target model in the mod directory."""
    return list(MOD_DIR.rglob(target_name))


def replace_models(dry_run: bool = False) -> None:
    """
    Replace all target models with their corresponding source models.

    Args:
        dry_run: If True, only print what would be done without making changes.
    """
    print(f"Exports directory: {EXPORTS_DIR}")
    print(f"Mod directory: {MOD_DIR}")
    print(f"Dry run: {dry_run}")
    print("-" * 60)

    total_replacements = 0

    for source_name, target_name in MODEL_REPLACEMENTS.items():
        print(f"\nProcessing: {source_name} -> {target_name}")

        # Find source model
        source_path = find_source_model(source_name)
        if source_path is None:
            print(f"  WARNING: Source model not found: {source_name}")
            continue

        print(f"  Source found: {source_path}")

        # Find all target models to replace
        target_paths = find_target_models(target_name)
        if not target_paths:
            print(f"  No target models found matching: {target_name}")
            continue

        print(f"  Found {len(target_paths)} target(s) to replace:")

        for target_path in target_paths:
            print(f"    - {target_path}")

            if not dry_run:
                # Copy source to target location, overwriting the target
                shutil.copy2(source_path, target_path)
                print("      REPLACED")
            else:
                print("      (would replace)")

            total_replacements += 1

    print("-" * 60)
    print(f"Total replacements: {total_replacements}")
    if dry_run:
        print("(Dry run - no files were modified)")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Replace target models in mod/ with source models from exports/"
    )
    parser.add_argument(
        "--dry-run",
        "-n",
        action="store_true",
        help="Show what would be done without making changes",
    )

    args = parser.parse_args()
    replace_models(dry_run=args.dry_run)
