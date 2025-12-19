#!/usr/bin/env bash

set -e

ask() {
    read -p "$1 (y/n): " ans
    if [ "$ans" = "y" ]; then
        return 0
    else
        return 1
    fi
}

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
# STEP 1
#######################################
step1() {
    echo "=== STEP 1 ==="
    cd ~/dvm

    # 1. go mod init
    go mod init github.com/vysmv/dvm

    # 2. create utils package
    mkdir -p ~/dvm/utils
    cat <<EOF > ~/dvm/utils/utils.go
package utils

import "fmt"

func Hello() {
    fmt.Println("Hello from utils!")
}
EOF

    # 3. initialize git
    git init
    git add .
    git commit -m "first commit"
    git branch -M main
    git remote add origin git@personal_gh:vysmv/dvm.git
    git push -u origin main
}

#######################################
# STEP 2
#######################################
step2() {
    echo "=== STEP 2 ==="

    # 1. rewrite main.go
    cat <<EOF > ~/first-contact/cmd/api/main.go
package main

import (
    "first-contact/internal/service"
    "github.com/vysmv/dvm/utils"
)

func main() {
    service.SayHello("from API")
}
EOF

    # 2. Go proxy & tidy operations
    export GOPROXY=direct
    rm -rf ~/go/pkg/mod/cache/download/github.com/vysmv/dvm
    cd ~/first-contact
    go clean -modcache
    export GOPRIVATE=github.com/vysmv/*
    go mod tidy
}

#######################################
# STEP 3
#######################################
step3() {
    echo "=== STEP 3 ==="
    local_clear

    # 1. update utils.go
    cat <<EOF > ~/dvm/utils/utils.go
package utils

import "fmt"

func Hello() {
    fmt.Println("Hello from utils!")
}

func NewFuncV0() {
    fmt.Println("Hello from utils!")
}
EOF

    # 2. git commit + tag v0.1.12
    cd ~/dvm
    git add .
    git commit -m "added new func for V0"
    git push
    git tag v0.1.12
    git push --tags

    # 3. run go mod tidy inside first-contact
    cd ~/first-contact
    go mod tidy
}

#######################################
# STEP 4
#######################################
step4() {
    echo "=== STEP 4 ==="

    # 1. update utils.go for V1
    cat <<EOF > ~/dvm/utils/utils.go
package utils

import "fmt"

func Hello() {
    fmt.Println("Hello from utils!")
}

func NewFuncV0() {
    fmt.Println("Hello from utils!")
}

func NewFuncV1() {
    fmt.Println("Hello from utils!")
}
EOF

    # 2. git commit + tag v1.0.0
    cd ~/dvm
    git add .
    git commit -m "added new func for V1"
    git push
    git tag v1.0.0
    git push --tags

    local_clear
    # 3. run go mod tidy
    cd ~/first-contact
    go mod tidy
}

#######################################
# STEP 5
#######################################
step5() {
    echo "=== STEP 5 ==="
    local_clear

    # 1–5. create v2 module and utils.go
    mkdir -p ~/dvm/v2/utils

    cd ~/dvm/v2
    go mod init github.com/vysmv/dvm/v2

    cat <<EOF > ~/dvm/v2/utils/utils.go
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
EOF

    # 6. git commit + tag v2.0.0
    cd ~/dvm
    git add .
    git commit -m "added v2"
    git push
    git tag v2.0.0
    git push --tags

    # 7. update first-contact main.go
    cat <<EOF > ~/first-contact/cmd/api/main.go
package main

import (
    "first-contact/internal/service"
    "github.com/vysmv/dvm/v2/utils"
)

func main() {
    service.SayHello("from API")
}
EOF

    # 8. run go mod tidy
    cd ~/first-contact
    go mod tidy
}

#######################################
# STEP 6
#######################################
step6() {
    echo "=== STEP 6 ==="
    local_clear

    # 1. rewrite main.go back to v1 import
    cat <<EOF > ~/first-contact/cmd/api/main.go
package main

import (
    "first-contact/internal/service"
    "github.com/vysmv/dvm/utils"
)

func main() {
    service.SayHello("from API")
}
EOF

    # 2. run go mod tidy
    cd ~/first-contact
    go mod tidy
}

#######################################
# RUN STEPS
#######################################

if ask "Run step #1?"; then step1; fi
if ask "Run step #2?"; then step2; fi
if ask "Run step #3?"; then step3; fi
if ask "Run step #4?"; then step4; fi
if ask "Run step #5?"; then step5; fi
if ask "Run step #6?"; then step6; fi

echo "Done!"