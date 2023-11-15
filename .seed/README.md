
# seed

This is the seed of the workspace.


## content

The seed directory will contain:

- ansible tasks
- ansible playbooks
- bash scripts
- pwsh scripts


## location

The seed directory location is determined by the seed meta file [seed.json](./../seed.json).

like this:

```json
{
  "seed": {
    "path": "seed",
    "customize": true
  }
}
```

## usage

The seed directory is shared with other workspaces through `git subrepo`.
