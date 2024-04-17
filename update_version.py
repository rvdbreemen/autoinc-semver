
import os
import re
import argparse
import subprocess
import logging

def parse_version_file(path):
    """ Parse the version file to extract version components. """
    print(f"DEBUG: Parsing file: {path}")
    version_info = {}
    try:
        with open(path, 'r') as file:
            for line in file:
                if line.startswith('#define '):
                    parts = line.split(' ', 2)
                    if len(parts) == 3:
                        key, value = parts[1], parts[2].strip()
                        print(f"DEBUG: Found key-value pair: {key} = {value}")
                        if key == '_VERSION_MAJOR':
                            version_info['MAJOR'] = value
                        elif key == '_VERSION_MINOR':
                            version_info['MINOR'] = value
                        elif key == '_VERSION_PATCH':
                            version_info['PATCH'] = value
                        elif key == '_VERSION_BUILD':
                            version_info['BUILD'] = value
                        elif key == '_VERSION_PRERELEASE':
                            version_info['PRERELEASE'] = value
    except FileNotFoundError:
        logging.error(f"Version file not found: {path}")
        exit(1)
    except Exception as e:
        logging.error(f"Error reading version file {path}: {e}")
        exit(1)
    
    print(f"DEBUG: Version Information: {version_info}")
    return version_info

def update_files(directory, version_info, ext_list):
    """ Update version in files within the specified directory. """
    if not os.path.exists(directory):
        print(f"ERROR: Directory {directory} does not exist.")
        return
    if not os.listdir(directory):
        print(f"ERROR: Directory {directory} is empty.")
        return
    print(f"DEBUG: Starting update_files with directory={directory}, version_info={version_info}, ext_list={ext_list}")
    for root, dirs, files in os.walk(directory):
        print(f"DEBUG: Processing directory: {root}")
        print(f"DEBUG: Subdirectories: {dirs}")
        print(f"DEBUG: Files: {files}")
        for file in files:
            _, ext = os.path.splitext(file)
            if ext in ext_list:
                print(f"DEBUG: Processing file: {file} with extension: {ext}")
                try:
                    update_version_in_file(os.path.join(root, file), version_info)
                    print(f"DEBUG: Successfully updated file: {file}")
                except Exception as e:
                    print(f"ERROR: Failed to update file {file}. Error: {e}")
            else:
                print(f"DEBUG: Skipping file: {file} with extension: {ext}")

def update_version_in_file(filepath, version_info):
    """ Replace the version string in the specified file. """
    pre_version_text = r"(\*\*\s*Version\s*:\s*v)(\d+\.\d+\.\d+)"
    version_pattern = re.compile(pre_version_text)
    new_version = f"{version_info['MAJOR']}.{version_info['MINOR']}.{version_info['PATCH']}"
    if 'PRERELEASE' in version_info:
        new_version += f"-{version_info['PRERELEASE']}"
    # new_version += f"+{version_info['BUILD']}"

    with open(filepath, 'r') as file:
        content = file.read()
    
    # print("Before update:")
    # print('\n'.join(content.splitlines()[:10]))

    # Use a lambda function for the replacement in the sub method
    updated_content = version_pattern.sub(lambda m: m.group(1) + new_version, content)

    # print("After update:")
    # print('\n'.join(updated_content.splitlines()[:10]))

    with open(filepath, 'w') as file:
        file.write(updated_content)

def git_commit_changes(directory, version):
    """ Commit changes in the git repository. """
    subprocess.run(['git', 'add', '.'], cwd=directory)
    subprocess.run(['git', 'commit', '-m', f'Update version to {version}'], cwd=directory)
    subprocess.run(['git', 'tag', f'auto-update-version-{version}'], cwd=directory)

def main(directory, filename, git_enabled):
    directory = os.path.abspath(directory)
    os.chdir(directory)
    version_info = parse_version_file(filename)
    ext_list = ['.ino', '.h', '.c', '.cpp', '.js', '.css', '.html', '.inc']
    print(f"DEBUG: Stacking directory: {directory}")
    print(f"DEBUG: Version Information: {version_info}")
    print(f"DEBUG: Extensions: {ext_list}")
    version_file_path = os.path.join(directory, filename)
    if not os.path.exists(version_file_path):
        print(f"ERROR: Version file {version_file_path} does not exist. Cannot update the directory.")
        return
    update_files(directory, version_info, ext_list)
    if git_enabled:
        git_commit_changes(directory, f"{version_info['MAJOR']}.{version_info['MINOR']}.{version_info['PATCH']}+{version_info['BUILD']}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Update version in boilerplate of files.')
    parser.add_argument('directory', type=str, help='Directory to update files in')
    parser.add_argument('--filename', type=str, default='version.h', help='Filename of the version file')
    parser.add_argument('--git', action='store_true', help='Enable git integration')
    args = parser.parse_args()
    main(args.directory, args.filename, args.git)
