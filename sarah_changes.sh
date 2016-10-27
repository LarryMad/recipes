# Make sure that exactly one argument was given
if [ $# -ne 1 ]; then
    if [ $# -gt 1 ]; then
        echo "$0: Got more arguments than expected.  Expected exactly 1."
    else
        echo "$0: Did not receive enough arguments.  Expected exactly 1."
    fi

    echo "Usage: bash $0 <GitHub url>"
    exit
fi

# Save remote url
remote_url="$1"

clean_up() {
    temp_dir_name="$1"
    orig_dir_name="$2"

    cd "$orig_dir_name"
    rm -rf "$temp_dir_name"
    exit
}

# Create a temporary directory to collaborate in
temp_dir_name="recipes-$$"
orig_dir_name=`pwd`
repo_name="recipes"

mkdir "$temp_dir_name"
if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Failed to create temporary directory.  Try using cd to" \
         "switch to an empty directory, then try again."
    exit
fi

# Switch to the temporary directory and clone the remote repository
cd "$temp_dir_name"
git clone "$remote_url" "$repo_name"
if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Could not connect to remote repo \"$remote_url\"." \
         " Double-check the url you entered."
    clean_up "$temp_dir_name" "$orig_dir_name"
fi
cd "$repo_name"

# Make sure the repository is in the expected state
if [ ! -f chili-recipe.txt ]; then
    echo ""
    echo "ERROR: Specified remote repository does not contain" \
         "chili-recipe.txt.  Please check the state of your fork on GitHub. " \
         "Right now, your fork should have the same commit history as Larry's" \
         "repository."
    clean_up "$temp_dir_name" "$orig_dir_name"
elif [ `grep "cumin" chili-recipe.txt | wc -l` -eq 0 ]; then
    echo ""
    echo "WARNING: chili-recipe.txt in the remote repository does not contain" \
         "\"cumin\".  Please check the state of your fork on GitHub.  If you've" \
         "already run this code successfully, you should see the same commit history" \
         "as Larry's repository, followed by a commit by Sarah removing cumin.  Otherwise," \
         "your fork should have the same commit history as Larry's repository."
    clean_up "$temp_dir_name" "$orig_dir_name"
elif [ `grep "cumin" chili-recipe.txt | wc -l` -ne 2 ]; then
    echo ""
    echo "ERROR: chili-recipe.txt in the remote repository should contain" \
         "exactly two occurrences of \"cumin\", but it does not.  Please check" \
         "the state of your fork on GitHub.  Right now, your fork should have" \
         "the same commit history as Larry's repository."
    clean_up "$temp_dir_name" "$orig_dir_name"
fi

# Configure only this directory to make Sarah the committer
git config user.name "Sarah Spikes"
git config user.email "sarah+github@udacity.com"

# Remove cumin from the chili recipe
sed '/ground cumin/d' chili-recipe.txt > chili-recipe-$$.txt
mv chili-recipe-$$.txt chili-recipe.txt
sed 's/, cumin//' chili-recipe.txt > chili-recipe-$$.txt
mv chili-recipe-$$.txt chili-recipe.txt

# Commit and push changes
git add chili-recipe.txt
git commit -m "Remove cumin from chili"
git push origin master

# Cleanup
clean_up "$temp_dir_name" "$orig_dir_name"
