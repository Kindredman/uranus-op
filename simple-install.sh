#!/bin/bash

# Simple Uranus-OP Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/Kindredman/uranus-op/main/simple-install.sh | bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing uranus-op...${NC}"

# Clone repository
echo -e "${BLUE}Cloning repository...${NC}"
cd /tmp
rm -rf uranus-op
git clone https://github.com/Kindredman/uranus-op.git
cd uranus-op

# Install dependencies
echo -e "${BLUE}Installing dependencies...${NC}"
npm install

# Build project
echo -e "${BLUE}Building project...${NC}"
npm run build

# Bundle project
echo -e "${BLUE}Bundling project...${NC}"
npm run bundle

# Install globally
echo -e "${BLUE}Installing globally...${NC}"
sudo npm install -g .

echo -e "${GREEN}Installation complete! You can now run 'uranus' command.${NC}"