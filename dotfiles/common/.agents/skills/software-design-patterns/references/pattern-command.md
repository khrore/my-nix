<!-- markdownlint-disable MD013 -->

# Command

## Problem

An operation must be represented as data for queuing, retries, audit, scheduling, macros, or undo.

## Direct Shape

```ts
await sendEmail(user.email, template, now());
audit("sent");
```

## Pattern Shape

```ts
type SendEmailCommand = { kind: "send-email"; userId: UserId; template: string };

async function handle(command: SendEmailCommand) {
  const user = await users.require(command.userId);
  await mailer.send(user.email, command.template);
}
```

## Tests

- Command serializes if it is queued.
- Handler success and failure are tested.
- Retry or idempotency behavior is explicit.

## Misuse Signals

- Direct call is sufficient.
- Command reads hidden globals instead of carrying input.
- The implementation introduces more concepts than the requirement needs.
