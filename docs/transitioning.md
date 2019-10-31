# Transitioning to Pipelines

This document outlines transitioning to pipelines.

## Pipelines with 2.0 Configuration

When using 2.0 configuration in combination with pipelines, CircleCI
will inject the `CIRCLE_COMPARE_URL` environment variable into all
jobs for backwards compatibility. This environment variable is
generated in a different way than the one that is available in legacy
jobs, and is not always available.

It is not injected when there is no meaningful previous revision,
which includes the first push of commits to an empty repository, and
when a new branch is created/pushed without any additional commits.
