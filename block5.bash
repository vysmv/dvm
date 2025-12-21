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
# MAIN BRANCH RELEASE FLOW
#######################################

echo "=== SWITCH TO MAIN ==="

# 1. Switch to main branch
cd "$HOME/dvm"
git switch main

#######################################
# v2.2.33
#######################################

echo "=== PREPARE v2.2.33 ==="

# 2. Rewrite utils.go for v2.2.33
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

func NewFuncV2_2_33() {
    fmt.Println("Hello from utils!")
}
EOF

# 3. Commit, push, tag v2.2.33
git add .
git commit -m "added new func for v2.2.33"
git push
git tag v2.2.33
git push --tags

#######################################
# v2.5.66
#######################################

echo "=== PREPARE v2.5.66 ==="

# 4. Rewrite utils.go for v2.5.66
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

func NewFuncV2_2_33() {
    fmt.Println("Hello from utils!")
}

func NewFuncV2_5_66() {
    fmt.Println("Hello from utils!")
}
EOF

# 5. Commit, push, tag v2.5.66
git add .
git commit -m "added new func for v2.5.66"
git push
git tag v2.5.66
git push --tags

#######################################
# CONSUMER UPDATE
#######################################

# 6. Run local_clear
local_clear

# 7. Get v2.2.33 in first-contact
cd "$HOME/first-contact"
go get github.com/vysmv/dvm/v2@v2.2.33

echo "Done."