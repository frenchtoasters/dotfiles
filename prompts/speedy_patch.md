---
name: Make Speedy Patch for Up + Tiltfile
interaction: chat
description: Outputs a unified diff patch to implement cmd/<project>-up.go steps and add local_resource to assets/<project>.Tiltfile
opts:
  alias: speedy-patch
  auto_submit: true
---

## system

Output ONLY a unified diff patch in a single ```diff``` block.
No prose.
Patch should apply with: git apply -p0

## user

Generate a unified diff patch that:
1) Updates cmd/<project>-up.go to implement a real up command using exec.Command steps + helper, adding flags:
   --project-dir
   --gcloud-project
2) Updates assets/<project>.Tiltfile to insert the local_resource block into the compose/composer function:

local_resource(
    "<project>",
    serve_cmd = [speedy_bin, "<project>-up", "--issue", issue],
    dir = project_dir,
    labels = ["addon"],
    env = {"ORIGINAL_CWD": original_cwd},
)

If one of the files is missing, patch only the existing one and include a comment line starting with # stating what was missing.

(Use the file contents I already provided in the other prompts, or ask me to paste them if needed.)
