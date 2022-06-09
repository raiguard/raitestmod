#!/bin/sh

# Extract version for later use
grep 'Version:' changelog.txt | awk '{print $2}' | head -1 > ../version
version=$(cat ../version)

# Datestamp changelog and commit
sed -i "3s/.*/Date: $(date -I)/" changelog.txt
git add changelog.txt
git commit -m "Prepare to release version $version"

# Create tag with changelog
changelog=$(awk "/Version: $version$/ { flag = 1 } /^--/ { flag = 0 } flag { gsub(/^  /, \"\"); print }" changelog.txt | tail -n +3)
git tag v$version -a -m "$changelog"

# Create archive and upload it
git archive --format=zip --prefix=raitestmod/ HEAD -o raitestmod_$version.zip
# fmm publish raitestmod_$version.zip

# Increment version
newversion=$(echo "$version" | awk 'BEGIN { FS = "."; OFS = "." } { print $1, $2, $3 + 1 }')
sed -i "s/^  \"version\":.*\$/  \"version\": \"$newversion\",/" info.json
echo -e "---------------------------------------------------------------------------------------------------\nVersion: $newversion\nDate: ????\n  Features:\n$(cat changelog.txt)" > changelog.txt

git add changelog.txt info.json
git commit -m "Move to version $newversion"

git push --atomic origin main v$version
