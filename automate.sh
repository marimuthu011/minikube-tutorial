#!/bin/bash

# Function to perform git push
git_push() {
    commit_message=$1
    branch_name=`git rev-parse --abbrev-ref HEAD`
    commit_id=`git rev-parse --short HEAD`

    echo -e "Running git pull...\n"
    git pull
    if [ $? -ne 0 ]; then
        echo -e "Git pull failed. Please resolve conflicts manually.\n"
        exit 1
    fi

    echo -e "Running git add...\n"
    git add .

    echo -e "Running git commit...\n"
    git commit -m "$commit_message"
    if [ $? -ne 0 ]; then
        echo -e "Git commit failed. Please ensure you have changes to commit.\n"
        exit 1
    fi

    echo -e "Running git push...\n"
    git push -u origin "$branch_name"
    if [ $? -eq 0 ]; then
        echo -e "Git push completed successfully.\n"
    else
        echo -e "Git push failed.\n"
        exit 1
    fi

    echo -e "Now the commit ID is ${commit_id} "
}

npm_build() {
    npm install
    npm run build
}

# Function to build and push Docker image
build_and_push_image() {
    GIT_COMMIT_ID=$(git rev-parse --short HEAD)
    DOCKERFILE_NAME=DockerFile
    APP_DOCKER_NAME=observe-apm-ui

    echo -e "Running git pull...\n"
    git pull
    if [ $? -ne 0 ]; then
        echo -e "Git pull failed. Please resolve conflicts manually.\n"
        exit 1
    fi

    echo -e "Building Docker image...\n"
    podman build -t quay.io/zagaos/$APP_DOCKER_NAME:$GIT_COMMIT_ID -f $DOCKERFILE_NAME .
    if [ $? -eq 0 ]; then
        echo -e "Docker image built successfully.\n"
        echo -e "Pushing Docker image...\n"
        podman push quay.io/zagaos/$APP_DOCKER_NAME:$GIT_COMMIT_ID
        if [ $? -eq 0 ]; then
            echo -e "Docker image of $APP_DOCKER_NAME pushed successfully.\n"
            echo -e "Tag name is $GIT_COMMIT_ID \n"
        else
            echo -e "Docker image $APP_DOCKER_NAME push failed.\n"
            exit 1
        fi
    else
        echo -e "Docker image build failed.\n"
        exit 1
    fi
}

# Function to display usage instructions
usage() {
    echo -e "Usage: $0 { git-push <commit-message> <branch-name> | mvn <maven-command> | build-and-push-image }\n"
    echo -e "  git-push <commit-message> <branch-name>  Run git push with commit message and branch name\n"
    echo -e "  build-push-image                     Build and push Docker image using the latest Git commit ID\n"
    exit 1
}

# Check if enough arguments are provided
if [ $# -lt 1 ]; then
    usage
fi

# Parse the command
command=$1
shift

case $command in
    git-push)
        if [ $# -lt 1 ]; then
            usage
        fi
        git_push "$@"
        ;;

    build-push-image)
        build_and_push_image
        ;;
    
    npm-build)
        npm_build
        ;;
    *)
        usage
        ;;
esac