<!-- markdownlint-disable MD013 -->

# Adapter

## Problem

External APIs, SDKs, CLIs, files, or services leak their shape into internal code.

## Direct Shape

```ts
async function charge(order: Order) {
  const result = await stripe.paymentIntents.create({ amount: order.totalCents });
  return result.status === "succeeded";
}
```

## Pattern Shape

```ts
interface PaymentPort {
  charge(amountCents: number): Promise<PaymentResult>;
}

class StripePaymentAdapter implements PaymentPort {
  async charge(amountCents: number) {
    const result = await stripe.paymentIntents.create({ amount: amountCents });
    return { ok: result.status === "succeeded" };
  }
}
```

## Tests

- Contract-test the port.
- Test adapter translation for success and provider failure.

## Misuse Signals

- Adapter mirrors every SDK method.
- External SDK types still flow through policy code.
- The implementation introduces more concepts than the requirement needs.
