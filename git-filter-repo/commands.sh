#!bin/bash

python3 ../git-filter-repo/git-filter-repo --analyze

# Keep only the specified path, removes everything else
python3 ../git-filter-repo/git-filter-repo --path <path to keep>

# You can specify more than one path to keep, removes everything else
python3 ../git-filter-repo/git-filter-repo --path <path to keep> --path <second-path-to-keep> --path <third-path-to-keep>

# Deletes the specified folder, must have the --invert-paths argument or it would delete everything but the specified path 
python3 ../git-filter-repo/git-filter-repo --path <folder to delete> --invert-paths

