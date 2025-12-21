#!/usr/bin/env bash

set -e

local_clear() {
    local file="$HOME/first-contact/cmd/api/main.go"
    local workdir="$HOME/first-contact"
    local saved_line

    # Read and save line 5
    saved_line="$(sed -n '5p' "$file")"

    # Remove line 5
    sed -i '5d' "$file"

    # Run go mod tidy in ~/first-contact
    cd "$workdir"
    go mod tidy

    # Restore the original line 5
    sed -i "5i\\$saved_line" "$file"
}

#######################################
# DEV BRANCH UPDATE
#######################################

echo "=== CREATE AND UPDATE DEV BRANCH ==="

# 1. Checkout dev branch in ~/dvm
cd "$HOME/dvm"
git checkout -b dev

# 2. Rewrite utils.go for v2
cat <<EOF > "$HOME/dvm/v2/utils/utils.go"
package utils

import "fmt"

func HelloNewAPI() {
    fmt.Println("Hello from utils!")
}

func NewFuncV0() {
    fmt.Println("Hello from utils!")
}

func NewFuncV1() {
    fmt.Println("Hello from utils!")
}

func NewFuncForDev() {
    fmt.Println("Hello from utils!")
}
EOF

# 3. Commit and push
git add .
git commit -m "added func for dev"

# 4. Push new branch and set upstream
git push --set-upstream origin dev

# 5. Run local_clear
local_clear

# 5.1 Rewrite line 5 in main.go to v2 import
sed -i '5s|.*|    "github.com/vysmv/dvm/v2/utils"|' \
    "$HOME/first-contact/cmd/api/main.go"

# 6. Go get dev branch in ~/first-contact
cd "$HOME/first-contact"
go get github.com/vysmv/dvm/v2@dev

echo "Done."