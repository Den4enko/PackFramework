import os
import shutil
import subprocess
from datetime import datetime

script_version = "v3"

def select_new_mp_version():
    script_root = os.path.dirname(os.path.abspath(__file__))
    last_version_file = os.path.join(script_root, 'packwiz', 'lastVersion.txt')

    if os.path.exists(last_version_file):
        with open(last_version_file, 'r') as f:
            last_version = f.read().strip()
    else:
        last_version = "noVersion"

    selected_mp_version = input(f"Select the new modpack version (Press Enter to keep {last_version}): ").strip()
    if not selected_mp_version:
        selected_mp_version = last_version

    with open(last_version_file, 'w') as f:
        f.write(selected_mp_version)

    print(selected_mp_version)
    return selected_mp_version

def build_modpack(mcversion, modpacktype, modloader, selected_mp_version):
    script_root = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_root, 'packwiz', modloader, mcversion, modpacktype)
    timestamp = datetime.now().strftime('%M:%S')

    print(f"[{timestamp}] Building {modloader}-{mcversion}-{modpacktype}...")

    # Clean up any old files in the output path
    print(f"[{timestamp}] Cleaning files...")
    if os.path.exists(output_path):
        shutil.rmtree(output_path)
    os.makedirs(output_path, exist_ok=True)

    # Merging files
    print(f"[{timestamp}] Merging...")
    source_paths = []

    # First, add 'shared' paths
    if modpacktype in ['server', 'nano', 'giga']:
        source_paths.append(os.path.join(script_root, 'source', 'shared', 'all', 'server'))
        source_paths.append(os.path.join(script_root, 'source', 'shared', mcversion, 'server'))
    if modpacktype in ['nano', 'giga']:
        source_paths.append(os.path.join(script_root, 'source', 'shared', 'all', 'nano'))
        if modpacktype == 'giga':
            source_paths.append(os.path.join(script_root, 'source', 'shared', 'all', 'giga'))
        nano_path = os.path.join(script_root, 'source', 'shared', mcversion, 'nano')
        if os.path.exists(nano_path):
            source_paths.append(nano_path)
        if modpacktype == 'giga':
            giga_path = os.path.join(script_root, 'source', 'shared', mcversion, 'giga')
            if os.path.exists(giga_path):
                source_paths.append(giga_path)

    # Then, add modloader-specific paths
    if modpacktype in ['server', 'nano', 'giga']:
        source_paths.append(os.path.join(script_root, 'source', modloader, 'all', 'server'))
        source_paths.append(os.path.join(script_root, 'source', modloader, mcversion, 'server'))
    if modpacktype in ['nano', 'giga']:
        source_paths.append(os.path.join(script_root, 'source', modloader, 'all', 'nano'))
        if modpacktype == 'giga':
            source_paths.append(os.path.join(script_root, 'source', modloader, 'all', 'giga'))
        nano_path = os.path.join(script_root, 'source', modloader, mcversion, 'nano')
        if os.path.exists(nano_path):
            source_paths.append(nano_path)
        if modpacktype == 'giga':
            giga_path = os.path.join(script_root, 'source', modloader, mcversion, 'giga')
            if os.path.exists(giga_path):
                source_paths.append(giga_path)

    for source_path in source_paths:
        if os.path.exists(source_path):
            for root, dirs, files in os.walk(source_path):
                relative_path = os.path.relpath(root, source_path)
                dest_path = os.path.join(output_path, relative_path)
                os.makedirs(dest_path, exist_ok=True)
                for file in files:
                    src_file = os.path.join(root, file)
                    dst_file = os.path.join(dest_path, file)
                    shutil.copy2(src_file, dst_file)

    # Remove files from filesToRemove.txt
    files_to_remove_path = os.path.join(output_path, 'filesToRemove.txt')
    if os.path.isfile(files_to_remove_path):
        print(f"[{timestamp}] Removing files from the list...")
        with open(files_to_remove_path, 'r') as f:
            for line in f:
                line = line.strip()
                file_to_remove = os.path.join(output_path, line.replace('/', os.sep))
                if os.path.exists(file_to_remove):
                    if os.path.isfile(file_to_remove):
                        os.remove(file_to_remove)
                    else:
                        shutil.rmtree(file_to_remove)
        os.remove(files_to_remove_path)

    # Change the versions
    print(f"[{timestamp}] Changing versions...")
    pack_toml_path = os.path.join(output_path, 'pack.toml')
    if os.path.isfile(pack_toml_path):
        with open(pack_toml_path, 'r') as f:
            content = f.read()
        content = content.replace('noVersion', selected_mp_version)
        with open(pack_toml_path, 'w') as f:
            f.write(content)

    if modpacktype in ['nano', 'giga']:
        meta_local_path = os.path.join(output_path, 'config', 'fancymenu', 'custom_locals', 'meta', 'en_us.local')
        if os.path.isfile(meta_local_path):
            with open(meta_local_path, 'r') as f:
                content = f.read()
            content = content.replace('noVersion', selected_mp_version)
            with open(meta_local_path, 'w') as f:
                f.write(content)

    # Update the modpack using packwiz
    print(f"[{timestamp}] Updating...")
    cwd = os.getcwd()
    os.chdir(output_path)
    subprocess.run(['packwiz', 'refresh'])
    subprocess.run(['packwiz', 'update', '--all', '-y'])
    os.chdir(cwd)
    print(f"[{timestamp}] Done!")

def build_modpack_set(modloader, mcversions, selected_mp_version):
    for mcversion in mcversions:
        for modpacktype in ['server', 'nano', 'giga']:
            build_modpack(mcversion, modpacktype, modloader, selected_mp_version)

def copy_packwiz_to_release():
    script_root = os.path.dirname(os.path.abspath(__file__))
    packwiz_path = os.path.join(script_root, 'packwiz')
    release_path = os.path.join(script_root, 'release')

    # Remove items in release folder
    if os.path.exists(release_path):
        shutil.rmtree(release_path)
    # Copy items from packwiz to release
    shutil.copytree(packwiz_path, release_path)
    # Remove lastVersion.txt from release
    last_version_file = os.path.join(release_path, 'lastVersion.txt')
    if os.path.exists(last_version_file):
        os.remove(last_version_file)

def select_mc_version():
    while True:
        print(f"[PackFramework Builder {script_version}]")
        print("Select versions to build:\n")
        print("1) All Versions\n")
        print("2) Forge 1.20.1")
        print("3) Fabric 1.20.1\n")
        print("0) Exit\n")
        selected_option = input("Enter number: ").strip()
        os.system('cls' if os.name == 'nt' else 'clear')

        if selected_option == '0':
            exit()
        elif selected_option == '1':
            selected_mp_version = select_new_mp_version()
            build_modpack_set('forge', ['1.20.1'], selected_mp_version)
            build_modpack_set('fabric', ['1.20.1'], selected_mp_version)
        elif selected_option == '2':
            selected_mp_version = select_new_mp_version()
            build_modpack_set('forge', ['1.20.1'], selected_mp_version)
        elif selected_option == '3':
            selected_mp_version = select_new_mp_version()
            build_modpack_set('fabric', ['1.20.1'], selected_mp_version)
        else:
            print("I'm sorry, but it seems you've selected the wrong option.")

if __name__ == '__main__':
    select_mc_version()
