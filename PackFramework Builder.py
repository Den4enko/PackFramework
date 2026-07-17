import os
import shutil
import subprocess
from datetime import datetime

script_version = "v6"


def select_new_mp_version():
    """
    Ask for a new modpack version, persist it to packwiz/lastVersion.txt,
    and return the selected version. Keeps the previous value if Enter is pressed.
    """
    script_root = os.path.dirname(os.path.abspath(__file__))
    last_version_file = os.path.join(script_root, 'packwiz', 'lastVersion.txt')

    if os.path.exists(last_version_file):
        with open(last_version_file, 'r', encoding='utf-8') as f:
            last_version = f.read().strip()
    else:
        last_version = "noVersion"

    selected_mp_version = input(
        f"Select the new modpack version (Press Enter to keep {last_version}): "
    ).strip() or last_version

    os.makedirs(os.path.dirname(last_version_file), exist_ok=True)
    with open(last_version_file, 'w', encoding='utf-8') as f:
        f.write(selected_mp_version)

    print(selected_mp_version)
    return selected_mp_version


def merge_sources_in_order(output_path, ordered_source_paths):
    """
    Merge multiple source directories into output_path.
    Later sources in the list override earlier ones on file conflicts.
    """
    for source_path in ordered_source_paths:
        if not os.path.exists(source_path):
            # It's okay if some folders don't exist; just skip them.
            print(f"[{datetime.now().strftime('%M:%S')}] Source not found, skipping: {source_path}")
            continue

        for root, dirs, files in os.walk(source_path):
            relative_path = os.path.relpath(root, source_path)
            dest_path = os.path.join(output_path, relative_path)
            os.makedirs(dest_path, exist_ok=True)

            for file in files:
                src_file = os.path.join(root, file)
                dst_file = os.path.join(dest_path, file)
                shutil.copy2(src_file, dst_file)


def prune_with_removal_list(output_path):
    """
    If filesToRemove.txt exists inside output_path, remove all listed files/dirs relative to output_path.
    """
    files_to_remove_path = os.path.join(output_path, 'filesToRemove.txt')
    if os.path.isfile(files_to_remove_path):
        print(f"[{datetime.now().strftime('%M:%S')}] Removing files from the list...")
        with open(files_to_remove_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                target = os.path.join(output_path, line.replace('/', os.sep))
                if os.path.exists(target):
                    if os.path.isfile(target):
                        os.remove(target)
                    else:
                        shutil.rmtree(target)
        os.remove(files_to_remove_path)


def apply_version_replacements(output_path, selected_mp_version):
    """
    Replace placeholders with the selected version in known files.
    """
    # pack.toml
    pack_toml_path = os.path.join(output_path, 'pack.toml')
    if os.path.isfile(pack_toml_path):
        with open(pack_toml_path, 'r', encoding='utf-8') as f:
            content = f.read()
        content = content.replace('noVersion', selected_mp_version)
        with open(pack_toml_path, 'w', encoding='utf-8') as f:
            f.write(content)

    # FancyMenu meta locale (for nano and giga, but harmless to try for all)
    meta_local_path = os.path.join(
        output_path, 'config', 'fancymenu', 'custom_locals', 'meta', 'en_us.local'
    )
    if os.path.isfile(meta_local_path):
        with open(meta_local_path, 'r', encoding='utf-8') as f:
            content = f.read()
        content = content.replace('noVersion', selected_mp_version)
        with open(meta_local_path, 'w', encoding='utf-8') as f:
            f.write(content)


def build_variant(modpacktype, selected_mp_version):
    """
    Build a single variant: server, nano, or giga.
    Merge order:
      - server: [server]
      - nano:   [server, nano]
      - giga:   [server, nano, giga]
    Then apply removals, apply version replacements, and run 'packwiz refresh'.
    """
    script_root = os.path.dirname(os.path.abspath(__file__))
    timestamp = datetime.now().strftime('%M:%S')

    source_root = os.path.join(script_root, 'source')
    packwiz_root = os.path.join(script_root, 'packwiz')
    output_path = os.path.join(packwiz_root, modpacktype)

    print(f"[{timestamp}] Building {modpacktype}...")

    # Clean output
    print(f"[{timestamp}] Cleaning files...")
    if os.path.exists(output_path):
        shutil.rmtree(output_path)
    os.makedirs(output_path, exist_ok=True)

    # Decide merge order
    if modpacktype == 'server':
        ordered_source_paths = [os.path.join(source_root, 'server')]
    elif modpacktype == 'nano':
        ordered_source_paths = [
            os.path.join(source_root, 'server'),
            os.path.join(source_root, 'nano'),
        ]
    elif modpacktype == 'giga':
        ordered_source_paths = [
            os.path.join(source_root, 'server'),
            os.path.join(source_root, 'nano'),
            os.path.join(source_root, 'giga'),
        ]
    else:
        raise ValueError("Unknown modpack type")

    # Merge
    print(f"[{timestamp}] Merging...")
    merge_sources_in_order(output_path, ordered_source_paths)

    # Prune
    prune_with_removal_list(output_path)

    # Version replacements
    print(f"[{timestamp}] Changing versions...")
    apply_version_replacements(output_path, selected_mp_version)

    # Refresh (no update)
    print(f"[{timestamp}] Refreshing packwiz indexes...")
    cwd = os.getcwd()
    try:
        os.chdir(output_path)
        subprocess.run(['packwiz', 'refresh', '--build'])
    finally:
        os.chdir(cwd)

    print(f"[{timestamp}] Done: {modpacktype}")


def build_all_variants(selected_mp_version):
    """
    Build server, nano, giga in the described cumulative order.
    """
    for variant in ['server', 'nano', 'giga']:
        build_variant(variant, selected_mp_version)


if __name__ == '__main__':
    print(f"[PackFramework Builder {script_version}]")
    version = select_new_mp_version()
    build_all_variants(version)
    print("[All done] Output is in the 'packwiz' folder (server, nano, giga).")