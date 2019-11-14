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

## Opting Into Pipelines on a Branch

There are two main ways of trying out pipelines on a branch without
committing by changing the project-wide setting. One of them is by
using version 2.1 configuration, the other is by including the
`experimental` stanza.

Note that these methods currently apply to webhooks as well as the
version 2 "pipeline trigger" API, but not the version 1.1 "job
trigger" API yet. We will announce support for using the version 1.1
API with pipelines soon.

### Using Version 2.1 Configuration

Configuration version 2.1 has always depended on pipelines. We are now
enabling pipelines for build requests with version 2.1 configuration
automatically, so trying out pipelines on a branch this way only
requires upgrading the configuration version.

This also allows use of the 2.1-exclusive features, like pipeline
values.

### Using the `experimental` Stanza

Alternatively there is a configuration stanza which enables pipelines
using a version 2.0 configuration:

```yaml
experimental:
  pipelines: true
```
