## Overview

This script helps in managing and cleaning up older builds in the SAP Commerce Cloud by deleting builds that are older than a specified period. The script fetches all builds associated with a specific subscription and deletes those older than three months.

## Requirements

- Bash
- curl
- jq

## Usage

1. **Run the script:**

    ```bash
    ./purgeOldBuilds.sh ENVIRONMENT_CODE API_KEY
    ```

## Script Details

- The script fetches all builds for the given subscription code using the `getBuilds` API.
- It calculates the timestamp for builds older than three months.
- It deletes builds that are older than the calculated timestamp using the `deleteBuild` API.

## How to Obtain Support
This repository is provided "as-is"; SAP does not provide any additional support.