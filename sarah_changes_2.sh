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
    echo "ERROR: Could not connect to remote repo $remote_url." \
         " Double-check the url you entered."
    clean_up "$temp_dir_name" "$orig_dir_name"
fi
cd "$repo_name"

# Make sure the repository is in the expected state
if [ ! -f cake-recipe.txt ]; then
    echo ""
    echo "ERROR: Specified remote repository does not contain" \
         "cake-recipe.txt.  Please check the state of your fork on GitHub." \
         "Right now, the most recent commit on your fork should be the commit" \
         "you made merging your spice addition and Sarah's cumin deletion."
    clean_up "$temp_dir_name" "$orig_dir_name"
elif [ `grep "1/2 cup" cake-recipe.txt | wc -l` -eq 0 ]; then
    echo ""
    echo "WARNING: cake-recipe.txt in the remote repository does not contain" \
         "\"1/2 cup\".  Please check the state of your fork on GitHub.  If you've" \
         "already run this code successfully, you should see a commit by Sarah adding" \
         "more oil.  Otherwise, the most recent commit on your fork should be the" \
         "commit you made merging your spice addition and Sarah's cumin deletion."
    clean_up "$temp_dir_name" "$orig_dir_name"

elif [ `grep "1/2 cup" cake-recipe.txt | wc -l` -ne 1 ]; then
    echo ""
    echo "ERROR: cake-recipe.txt in the remote repository contains more" \
         "than one occurrence of \"1/2 cup\".  Please check the state" \
         "of your fork on GitHub.  Right now, the most recent commit on" \
         "your fork should be the commit you made merging your spcie addition" \
         "and Sarah's cumin deletion."
    clean_up "$temp_dir_name" "$orig_dir_name"
fi

# Configure only this directory to make Sarah the committer
git config user.name "Sarah Spikes"
git config user.email "sarah+github@udacity.com"

# Remove cumin from the chili recipe
sed 's:1/2 cup:3/4 cup:' cake-recipe.txt >> cake-recipe-$$.txt
mv cake-recipe-$$.txt cake-recipe.txt

# Commit and push changes
git add cake-recipe.txt
git commit -m 'Merge pull request from more-oil

Add more oil so the cake is more moist!'
git push origin master

# Cleanup
clean_up "$temp_dir_name" "$orig_dir_name"
