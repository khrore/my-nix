<!-- markdownlint-disable MD013 -->

# State

## Problem

Behavior changes substantially by lifecycle state, and valid transitions matter.

## Direct Shape

```ts
if (order.status === "draft") { /* ... */ }
if (order.status === "paid") { /* ... */ }
if (order.status === "shipped") { /* ... */ }
```

## Pattern Shape

```ts
class PaidOrderState implements OrderState {
  ship(order: Order) { order.transitionTo(new ShippedOrderState()); }
  cancel() { throw new InvalidTransition("paid cannot cancel here"); }
}
```

## Tests

- Valid transitions succeed.
- Invalid transitions fail clearly.
- State-specific behavior is covered.

## Misuse Signals

- State is a simple flag.
- Transition logic remains scattered.
- The implementation introduces more concepts than the requirement needs.
