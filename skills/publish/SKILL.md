---
name: publish
description: >
  Package and release a World of Warcraft Forever addon: the BigWigs packager in GitHub
  Actions, .pkgmeta for an addon that lives in a subfolder, @project-version@ in the .toc,
  annotated tags, and where a Forever build can be published (GitHub Releases, CurseForge
  and Wago supported; WoWInterface not supported by the packager for Forever). Use when
  setting up releases for an addon, cutting a release, adding CurseForge or Wago upload,
  choosing where to publish, or debugging a release run that failed or skipped an upload.
  For the .toc header itself and the interface number use the build skill and
  reference/guides/packaging.md.
---

# Publishing a Forever addon

The standard tool is the [BigWigs packager](https://github.com/BigWigsMods/packager)
(`BigWigsMods/packager@v2`, a GitHub Action). It already knows Forever: `release.sh` maps
any `## Interface: 16???` to game type `forever` and names the zip `<Name>-<tag>-forever.zip`.

What this page rests on: a reading of `release.sh` as fetched on 2026-09-25, and one real
release run on that date, `imperial64/dynamic-ambiance-forever` v0.3.0. That run built the
zip, created the GitHub Release, and reported `"flavor":"forever","interface":16001` in
`release.json`. **CurseForge and Wago uploads were not exercised in that run**, because no
project IDs existed yet. The packager changes over time, so recheck `release.sh` when
something looks off.

## Where a Forever build can go

| Site | Packager support for Forever | Needs |
|---|---|---|
| GitHub Releases | **Yes**, verified by the v0.3.0 run | Nothing. `GITHUB_TOKEN` is provided; the workflow needs `permissions: contents: write` |
| CurseForge | Yes: `forever` maps to CurseForge game id `88568`. CurseForge has had a Forever flavour since 2026-09-18 | `## X-Curse-Project-ID: <digits>` in the `.toc`, and a `CF_API_KEY` secret |
| Wago | Yes: `forever` maps to Wago's `forever` type. Wago's `/api/data/game` listed `forever` with patch `1.60.1` on 2026-09-25 | `## X-Wago-ID: <id>` in the `.toc`, and a `WAGO_API_TOKEN` secret |
| WoWInterface | **No.** `upload_wowinterface` prints `No WoWInterface game type match for "forever" ... ignoring` | Leave `## X-WoWI-ID` out of the `.toc`, or the run fails. Upload the GitHub zip there by hand |

An upload whose project ID is missing from the `.toc`, or whose token is empty, is skipped
without an error. So the workflow can carry all the secrets from day one, and a tag makes
only the GitHub Release until the sites are set up. Creating the site projects, and adding
the API keys as repository secrets, is the maintainer's job, done by a person. Never put a
token in a file.

## The workflow

`.github/workflows/release.yml`, from the packager wiki's "GitHub Actions workflow" page,
with one packager step:

```yaml
name: Package and release

on:
  push:
    tags:
      - '**'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    env:
      CF_API_KEY: ${{ secrets.CF_API_KEY }}
      WOWI_API_TOKEN: ${{ secrets.WOWI_API_TOKEN }}
      WAGO_API_TOKEN: ${{ secrets.WAGO_API_TOKEN }}
      GITHUB_OAUTH: ${{ secrets.GITHUB_TOKEN }}
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0   # the packager reads history for versions and changelogs
      - uses: BigWigsMods/packager@v2
```

`actions/checkout` was at v7 (v7.0.1) and the packager at v2 (v2.6.1) on 2026-09-25. If a
run fails with "Resource not accessible by integration", set Settings → Actions → General →
Workflow permissions to "Read and write".

## `.pkgmeta`

The packager packages the repository root. If the addon lives in a subfolder, which is
common when the repository also holds tests, docs and design notes, move it into place and
ignore the rest:

```yaml
package-as: MyAddon

move-folders:
  MyAddon/addons/MyAddon: MyAddon

manual-changelog:
  filename: CHANGELOG.md
  markup-type: markdown

ignore:
  - tests
  - docs
  - scripts
  - README.md
  - CHANGELOG.md
```

Files starting with a dot are never packaged. A root `LICENSE` ends up inside the addon
folder. Use `manual-changelog` if the history is short or squashed; otherwise the
packager builds a changelog from commits.

## The `.toc`

```
## Interface: 16001
## Title: My Addon
## Version: @project-version@
## Author: <public name>
## X-Curse-Project-ID: 123456
## X-Wago-ID: abcd1234
```

The packager replaces `@project-version@` with the tag. A copy installed straight from the
repository still shows the literal keyword. If the addon reads its own version, treat the
unreplaced keyword as "development build" and don't write it into files. The directives
must stay contiguous (`toc-header-break`, see `reference/guides/packaging.md`).

## Cutting a release

1. Update `CHANGELOG.md` and run the addon's tests and the linter
   (`python tools/lint_addon.py <addon dir>`).
2. Commit, then make an **annotated** tag and push it:

   ```
   git tag -a v0.3.0 -m "v0.3.0"
   git push origin v0.3.0
   ```

3. Watch the run (`gh run watch`), then check the release. Download the zip and confirm it
   holds exactly one folder with the `.toc`, the files the `.toc` lists and `LICENSE`, and
   that the `.toc`'s version reads the tag. `release.json` should say
   `"flavor":"forever"`.

A tag containing `alpha` or `beta` is published as that release type; a plain `vX.Y.Z` is a
full release.

## Checking a package without uploading

From Git Bash, in a clean clone: the packager leaves out files git does not track. Keep
`release.sh` outside the repository:

```
curl -s -o ~/release.sh https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh
bash ~/release.sh -d -z     # -d: no upload; -z: no zip (Git Bash has no zip)
```

The result is in `.release/<Name>/`. Add `.release/` to `.gitignore`.

## Before the repository goes public

- Scrub measurement records and SavedVariables copies for the Battle.net account folder
  under `WTF\Account\`, character and realm names, other players' names (import senders,
  ignore lists, whisper targets), and local user paths. Remember the history carries them
  too. Publishing a fresh single commit, and keeping the old history on a local branch that
  is never pushed, is the simple way out.
- Add a `LICENSE`, and a `.github/FUNDING.yml` if there is a support link.
