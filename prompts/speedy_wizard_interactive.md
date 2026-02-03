---
name: Project Wizard (Interactive)
interaction: chat
description: Interactive wizard generate tiltfile, optionally scaffold+fill up, insert local_resource, output full patch
opts:
  alias: speedy-wizard-interactive
  auto_submit: true
---

## system

You must output EXACTLY what is between the <OUTPUT> tags.
Do not add commentary. Do not reformat. Do not wrap in markdown.
If the output contains a diff, preserve it verbatim.

## user

```
${speedy_wizard_interactive.run}
```
