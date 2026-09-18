<!-- markdownlint-disable MD013 -->

# Observer

## Problem

One subject change should notify multiple dependent observers.

## Direct Shape

```ts
function updateOrder(order: Order) {
  save(order);
  email(order);
  refreshDashboard(order);
}
```

## Pattern Shape

```ts
orderEvents.subscribe(emailOnOrderChange);
orderEvents.subscribe(refreshDashboard);
save(order);
orderEvents.publish({ kind: "order-updated", orderId: order.id });
```

## Tests

- Multiple observers receive the event.
- Observer failure behavior is defined.
- Payload contains stable public data.
- The state change and notification ordering match the required consistency guarantees.

## Misuse Signals

- Events replace clear ownership.
- Observers rely on hidden order.
- The implementation introduces more concepts than the requirement needs.
