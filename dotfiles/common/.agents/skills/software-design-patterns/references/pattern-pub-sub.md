<!-- markdownlint-disable MD013 -->

# Pub-Sub

## Problem

Publishers and subscribers should not know each other, often across process, plugin, or subsystem boundaries.

## Direct Shape

```ts
checkout(order);
email(order);
analytics(order);
warehouse(order);
```

## Pattern Shape

```ts
bus.subscribe("order.checked-out", sendEmail);
bus.subscribe("order.checked-out", recordAnalytics);
checkout(order);
bus.publish("order.checked-out", { orderId: order.id });
```

## Tests

- Subscribers receive the correct topic payload.
- Unknown topic or handler failure behavior is defined.
- Payload schema is stable.
- Delivery, retry, duplication, and ordering guarantees match subscriber behavior.

## Misuse Signals

- In-process direct call is clearer.
- Events are used to dodge ownership.
- The implementation introduces more concepts than the requirement needs.
