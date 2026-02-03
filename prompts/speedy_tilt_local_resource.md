---
name: Add local_resource to Project Tiltfile
interaction: chat
description: Inserts local_resource(...) into the composer() function in assets/<project>.Tiltfile
opts:
  alias: speedy-tilt-local-resource
  auto_submit: true
---

## system

You are an expert Tiltfile/Starlark engineer.
You MUST ground edits in the exact Tiltfile content provided.
This generated Tiltfile defines: project_dir, issue, original_cwd, speedy_bin, compose_file_abs_dir, and a composer() function that calls docker_compose(...), then calls composer() at the end.

Insertion rule:
- Insert the local_resource block inside composer(), after docker_compose(...).

Output requirement:
- Output the full final Tiltfile content.

## user

Update assets/<project>.Tiltfile by inserting this block into composer() **after** docker_compose(...):

local_resource(
    "<project>",
    serve_cmd = [speedy_bin, "<project>-up", "--issue", issue],
    dir = project_dir,
    labels = ["addon"],
    env = {"ORIGINAL_CWD": original_cwd},
)

Replace <project> with the actual project name derived from the args passed to this prompt.

Here is the current Tiltfile:

```python
${speedy_tilt_local_resource.context}
```
