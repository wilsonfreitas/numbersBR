---
goal: Add GitHub Actions CI/CD workflows for R-CMD-check, test coverage, linting, and pkgdown documentation
version: '1.0'
date_created: 2026-02-24
last_updated: 2026-02-24
owner: wilsonfreitas
status: 'Implemented'
tags: [feature, ci, github-actions, chore]
---

# Introduction

![Status: Implemented](https://img.shields.io/badge/status-Implemented-green)

Add four GitHub Actions workflows to the `numbersBR` R package to enable automated CI/CD: R CMD CHECK across multiple platforms and R versions, test coverage reporting via `covr` + Codecov, static code linting via `lintr`, and automated `pkgdown` documentation site deployment to GitHub Pages.

## 1. Requirements & Constraints

- **REQ-001**: An `R-CMD-check` workflow must run `R CMD CHECK` on push and pull-request events targeting `master`.
- **REQ-002**: A `test-coverage` workflow must compute line coverage using `covr::package_coverage()` and upload results to Codecov via the official `codecov/codecov-action`.
- **REQ-003**: All workflows must use `r-lib/actions@v2` for R setup and dependency installation.
- **REQ-004**: Package requires R >= 4.0.0 (declared in `DESCRIPTION`).
- **REQ-005**: The only runtime import is `stringr`; `testthat` and `covr` are `Suggests`.
- **CON-001**: No terminal access during implementation — all files must be created via editor tooling.
- **CON-002**: Codecov token is already present in `codecov.yml` but must also be stored as `CODECOV_TOKEN` repository secret for the workflow action.
- **CON-003**: `pkgdown` is not currently listed in `DESCRIPTION`; it must only be installed as an extra package inside the workflow, not added as a package dependency.
- **GUD-001**: Use `actions/checkout@v4` and pin all third-party actions to a specific major version tag.
- **GUD-002**: Set `GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}` in all jobs to avoid GitHub API rate-limit errors during dependency installation.
- **PAT-001**: Follow the canonical r-lib/actions workflow patterns (https://github.com/r-lib/actions/tree/v2/examples).

## 2. Implementation Steps

### Implementation Phase 1 — Mandatory Workflows

- GOAL-001: Create the `R-CMD-check` and `test-coverage` workflows, which are explicitly required by the user.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Create `.github/workflows/R-CMD-check.yml` — triggers on push/PR to `master`; matrix of `{ubuntu-latest, windows-latest, macos-latest} × release`, plus `ubuntu-latest × {devel, oldrel-1}`; uses `r-lib/actions/check-r-package@v2` | ✅ | 2026-02-24 |
| TASK-002 | Create `.github/workflows/test-coverage.yml` — triggers on push/PR to `master`; runs `covr::package_coverage()`, converts to Cobertura XML with `covr::to_cobertura()`, uploads via `codecov/codecov-action@v4` with `CODECOV_TOKEN` secret | ✅ | 2026-02-24 |
| TASK-003 | Add `CODECOV_TOKEN` repository secret in GitHub → Settings → Secrets → Actions (value: `1a7e6cff-223e-4dd3-aaca-2b1c3e280906` from existing `codecov.yml`) | | |

### Implementation Phase 2 — Recommended Workflows

- GOAL-002: Add `lint` and `pkgdown` workflows following R community best practices.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-004 | Create `.github/workflows/lint.yml` — triggers on push/PR to `master`; installs `lintr` as extra package; runs `lintr::lint_package()`; sets `LINTR_ERROR_ON_LINT: true` so the job fails on lint errors | ✅ | 2026-02-24 |
| TASK-005 | Create `.github/workflows/pkgdown.yml` — triggers on push to `master`, on published releases, and via `workflow_dispatch`; builds docs with `pkgdown::build_site_github_pages()`; deploys to `gh-pages` branch via `JamesIves/github-pages-deploy-action@v4` | ✅ | 2026-02-24 |
| TASK-006 | Enable GitHub Pages in repository settings: source = `gh-pages` branch, folder = `/ (root)` | | |

## 3. Alternatives

- **ALT-001**: Use Travis CI or CircleCI instead of GitHub Actions — not chosen because GitHub Actions is natively integrated with the repository, has free minutes for public repos, and is the current R community standard.
- **ALT-002**: Use a single monolithic workflow file with multiple jobs instead of separate files — not chosen because separate files allow individual re-runs, clearer status badges per concern, and independent trigger conditions.
- **ALT-003**: Upload coverage using `covr::codecov()` directly (legacy method) instead of `covr::to_cobertura()` + `codecov/codecov-action` — not chosen because the action-based approach is the Codecov-recommended method and supports tokens reliably.
- **ALT-004**: Pin `lintr` linting rules via a `.lintr` config file at the repo root — not chosen in scope of this plan; can be added later if lint noise becomes an issue given the mixed-indentation style across files.

## 4. Dependencies

- **DEP-001**: `r-lib/actions@v2` — GitHub Actions toolkit for R; provides `setup-r`, `setup-r-dependencies`, `check-r-package`, `setup-pandoc`.
- **DEP-002**: `codecov/codecov-action@v4` — Official Codecov uploader action; requires `CODECOV_TOKEN` repository secret.
- **DEP-003**: `JamesIves/github-pages-deploy-action@v4` — Deploys a folder to a target branch; used for `gh-pages` deployment.
- **DEP-004**: `covr` R package — Already listed in `Suggests` in `DESCRIPTION`; installed as extra package in coverage workflow.
- **DEP-005**: `lintr` R package — Not currently in `DESCRIPTION`; installed as extra package only inside the lint workflow.
- **DEP-006**: `pkgdown` R package — Not currently in `DESCRIPTION`; installed as extra package only inside the pkgdown workflow.

## 5. Files

- **FILE-001**: `.github/workflows/R-CMD-check.yml` — New file. Defines multi-platform R CMD CHECK CI job.
- **FILE-002**: `.github/workflows/test-coverage.yml` — New file. Defines coverage measurement and Codecov upload job.
- **FILE-003**: `.github/workflows/lint.yml` — New file. Defines lintr linting job.
- **FILE-004**: `.github/workflows/pkgdown.yml` — New file. Defines pkgdown build and GitHub Pages deploy job.

## 6. Testing

- **TEST-001**: Push a commit to `master` and verify all four workflow runs appear under the repository's "Actions" tab with green status.
- **TEST-002**: Open a pull request and verify `R-CMD-check` and `test-coverage` status checks are reported on the PR.
- **TEST-003**: After a successful `test-coverage` run, verify the coverage report appears on Codecov dashboard at `https://app.codecov.io/gh/wilsonfreitas/numbersBR`.
- **TEST-004**: After a successful `pkgdown` run, verify the documentation site is accessible at `https://wilsonfreitas.github.io/numbersBR/`.
- **TEST-005**: Introduce a deliberate lint violation (e.g., trailing whitespace) in a branch and verify the `lint` workflow fails on that PR.

## 7. Risks & Assumptions

- **RISK-001**: Mixed indentation (tabs in `CPF.R`/`CNPJ.R`, spaces in `RENAVAN.R`) may trigger `lintr` indentation warnings and fail the lint job immediately. Mitigation: add a `.lintr` config disabling `indentation_linter` if needed.
- **RISK-002**: `RoxygenNote: 6.0.1` in `DESCRIPTION` is outdated; `R CMD CHECK` on newer R may warn about version mismatch. Mitigation: treat as a NOTE, not an ERROR, for now; update `roxygen2` in a separate task.
- **RISK-003**: The Codecov token hardcoded in `codecov.yml` is a repository-level token and may have rotated. Assumption: token is still valid; if uploads fail, regenerate from Codecov dashboard.
- **ASSUMPTION-001**: The repository is public on GitHub, so `actions/checkout`, `r-lib/actions`, and GitHub Pages are available without additional billing.
- **ASSUMPTION-002**: GitHub Pages is not yet enabled for this repository; TASK-006 must be performed manually via the GitHub web UI.

## 8. Related Specifications / Further Reading

- [r-lib/actions example workflows](https://github.com/r-lib/actions/tree/v2/examples)
- [Codecov GitHub Action v4](https://github.com/codecov/codecov-action)
- [pkgdown — Automated deployment to GitHub Pages](https://pkgdown.r-lib.org/articles/pkgdown.html#deployment)
- [lintr — Static code analysis for R](https://lintr.r-lib.org/)
- [JamesIves/github-pages-deploy-action](https://github.com/JamesIves/github-pages-deploy-action)
