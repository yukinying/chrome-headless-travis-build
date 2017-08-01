#!/bin/bash
[ -f chrome.fetched ] || sudo apt-get -y update
[ -f chrome.fetched ] || sudo apt-get -y install git python
[ -f chrome.fetched ] || echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && sudo apt-get install -y ttf-mscorefonts-installer
[ -f chrome.fetched ] || (git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git && cd depot_tools && git pull)
[ -f chrome.fetched ] || (mkdir -p ~/chromium && cd ~/chromium && fetch --no-history --nohooks chromium)
[ -f chrome.fetched ] || (cd ~/chromium/src && sudo ./build/install-build-deps.sh --no-prompt && touch chrome.fetched)
( git ls-remote --tags | grep refs | cut -d/ -f3 | sort -rn | head -1 > target.txt ) && cat target.txt
export TARGET=`cat target.txt` && git fetch origin $TARGET --depth=1 
export TARGET=`cat target.txt` && git checkout $TARGET && gclient sync --no-history --with_branch_heads --with_tags --reset --shallow --jobs 16 && mkdir -p out/$TARGET && cp ~/args.gn out/$TARGET; gn gen out/$TARGET
export TARGET=`cat target.txt` && timeout 45m ninja -C out/$TARGET headless_shell || true
export TARGET=`cat target.txt` && cd out/$TARGET && mkdir -p bin && cp ~/Dockerfile *.pak headless_shell bin && sudo docker build -t yukinying/chrome-headless:$TARGET -t yukinying/chrome-headless:latest bin && sudo docker run --init --rm --entrypoint="/chrome/headless_shell" --name headless yukinying/chrome-headless:$TARGET --no-sandbox --disable-gpu "https://www.google.com" && sudo docker push yukinying/chrome-headless:$TARGET && sudo docker push yukinying/chrome-headless:latest
export TARGET=`cat target.txt` && cd out/$TARGET && ~/chrome-release-to-github.sh
export TARGET=`cat target.txt` && cd out/$TARGET && ~/npm-publish.sh
