# Project Knowledge Profile

> Save a tailored copy as `.omp/AGENTS.md` in the project. This file records facts and constraints; it does not prescribe which agent to use.

## Identity

- Purpose: [what this project does]
- Primary users: [who depends on it]
- Maintainers/owners: [teams or ownership model]

## Architecture

- Entry points: [application, service, CLI, jobs]
- Major layers and their responsibilities: [facts only]
- State/storage boundaries: [facts only]

## Ownership boundaries

- [Module/team] owns [area]. Changes outside that boundary need [specific coordination or constraint].

## Important modules

- `path/to/module`: [responsibility and invariants]

## Integration points

- [External system]: [protocol, contract, failure behavior, compatibility constraint]

## Sensitive business and technical boundaries

- [Area] is sensitive because [concrete reason: data, authorization, audit, contract, or operational impact].

## Framework and version discipline

- [Runtime/framework]: [supported versions and project-specific conventions]

## Verification environment

- Focused commands and prerequisites: [commands discovered from this repository]
- Constraints: [services, fixtures, environment variables—do not record secrets]

## Working-tree discipline

- [Local rules for generated files, migrations, or user-owned changes]

## Current-evidence principle

- Treat this profile as context, but verify current code, dependencies, and runtime facts before acting.

## Project-specific constraints

- [Concrete constraints, contracts, or non-negotiable behavior]
