# Config Processing Stages and Parameter Scopes

## Processing Stages

Configuration processing happens in the following stages:

-   Pipeline parameters are resolved and type-checked
-   Pipeline parameters are replaced in the orb statement
-   Orbs are imported
-   The remaining configuration is processed, element parameters are
    resolved, type-checked, and substituted

## Element Parameter Scope

Element parameters use lexical scoping, so parameters are in scope
within the element they are defined in, e.g. a job, a command, or an
executor. If a element with parameters calls another element with
parameters, like in the example below, the inner element does not
inherit the scope of the calling element.

```yaml
version: 2.1

commands:
    print:
    parameters:
        message:
        type: string
    steps:
        - run: echo << parameters.message >>

jobs:
    cat-file:
    parameters:
        file:
        type: string
    steps:
        - print:
            message: Printing << parameters.file >>
        - run: cat << parameters.file >>

workflows:
    my-workflow:
    jobs:
        - cat-file:
            file: test.txt
```

Even though the `print` command is called from the `cat-file` job, the
`file` parameter would not be in scope inside the `print`. This
ensures that all parameters are always bound to a valid value, and the
set of available parameters is always known.

## Pipeline Value Scope

Pipeline values, the pipeline-wide values that are provided by
CircleCI (e.g. `<< pipeline.number >>`) are always in scope.

## Pipeline Parameter Scope

Pipeline parameters which are defined in configuration are always in
scope, with two exceptions:

-   Pipeline parameters are not in scope for the definition of other
    pipeline parameters, so they cannot depend on one another
-   Pipeline parameters are not in scope in the body of orbs, even
    inline orbs, to prevent data leaks
