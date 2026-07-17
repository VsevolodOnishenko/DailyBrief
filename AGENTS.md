# DailyBrief project instructions

## Product

DailyBrief is an open-source iOS application that presents five concise
professional articles per day.

Read PRODUCT.md and ARCHITECTURE.md before proposing or making changes.

## Technical requirements

- Use Swift 6.3.
- Enable and respect strict concurrency.
- Use SwiftUI for presentation.
- Use Observation for feature state.
- Prefer async/await over Combine.
- Use Swift Testing for unit tests.
- Use URLSession when networking is introduced.
- Do not add third-party dependencies without explicit approval.
- Do not introduce SwiftData until a persistence use case is implemented.

## Architecture

- Organize production code by feature and responsibility.
- Keep domain entities independent from SwiftUI.
- Hide external data sources behind protocols.
- Inject dependencies through initializers.
- Keep the application target as the composition root.
- Avoid singleton services.
- Avoid generic base classes.
- Avoid abstractions with no clear testing or substitution benefit.

## Code quality

- Prefer small, focused types.
- Model errors explicitly.
- Support loading, content, empty, and failure states.
- Add accessibility labels where necessary.
- Do not suppress compiler warnings.
- Do not use force unwraps in production code.
- Do not add comments that merely repeat the code.

## Validation

After changing production code:

1. Build the app.
2. Run relevant tests.
3. Report the exact commands used.
4. Report warnings and failures honestly.
5. Do not claim success if a command failed.

## Git

- Do not commit changes.
- Do not modify signing settings.
- Do not rewrite unrelated files.
- Do not run destructive Git commands.
- Never add secrets or API keys.

## Scope discipline

Implement only the requested vertical slice.
Do not add networking, persistence, AI, subscriptions, analytics,
widgets, or additional features unless explicitly requested.
