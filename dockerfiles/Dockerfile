# Use the original rockerdev/tidyverse:4.0.0 image as the base
FROM rockerdev/tidyverse:4.0.0

# Update package list and install apt-utils, bsdmainutils, and coreutils
RUN apt-get update && apt-get install -y apt-utils bsdmainutils coreutils

# Optional: clean up apt cache to reduce image size
RUN rm -rf /var/lib/apt/lists/*
