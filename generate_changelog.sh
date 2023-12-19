    #!/bin/bash

    if [ $(git tag -l | wc -l) -ge 2 ]; then
        latest_tag=$(git describe --tags --abbrev=0);
        second_latest_tag=$(git describe --tags --abbrev=0 $latest_tag^);
        git log --pretty=format:"%s" $second_latest_tag..$latest_tag >> release_notes.md;
        git log --pretty=format:"%s" $second_latest_tag..$latest_tag;
    else
        git log --pretty=format:"%s" $(git rev-list --max-parents=0 HEAD)..HEAD >> release_notes.md;
        git log --pretty=format:"%s" $(git rev-list --max-parents=0 HEAD)..HEAD;
    fi
