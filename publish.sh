#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting publishing process...${NC}\n"

# Check flutter pub environment
echo -e "${YELLOW}Checking Flutter environment...${NC}"
if ! command -v flutter pub &> /dev/null; then
    echo -e "${RED}Flutter command not found! Please ensure Flutter SDK is properly installed.${NC}"
    exit 1
fi

# Set pub hosting to pub.dev
export PUB_HOSTED_URL=https://pub.dev

# Run tests
# echo -e "\n${YELLOW}Running tests...${NC}"
# flutter test
# if [ $? -ne 0 ]; then
#     echo -e "${RED}Tests failed! Please fix tests before continuing.${NC}"
#     exit 1
# fi

# Check code formatting
echo -e "\n${YELLOW}Checking code format...${NC}"
dart format --set-exit-if-changed lib test example
if [ $? -ne 0 ]; then
    echo -e "${RED}Code format check failed! Please run 'dart format .' to fix formatting issues.${NC}"
    exit 1
fi

# Analyze code
echo -e "\n${YELLOW}Analyzing code...${NC}"
flutter analyze
if [ $? -ne 0 ]; then
    echo -e "${RED}Code analysis found issues! Please fix the reported problems.${NC}"
    exit 1
fi

# Check pubspec.yaml
echo -e "\n${YELLOW}Validating pubspec.yaml...${NC}"
flutter pub publish --dry-run
if [ $? -ne 0 ]; then
    echo -e "${RED}pubspec.yaml validation failed! Please check the configuration.${NC}"
    exit 1
fi

# Confirm publishing
echo -e "\n${YELLOW}Ready to publish to pub.dev...${NC}"
read -p "Confirm publishing? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}Publishing...${NC}"
    flutter pub publish
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}Published successfully!${NC}"
    else
        echo -e "\n${RED}Publishing failed! Please check error messages.${NC}"
        exit 1
    fi
else
    echo -e "\n${YELLOW}Publishing cancelled${NC}"
    exit 0
fi 