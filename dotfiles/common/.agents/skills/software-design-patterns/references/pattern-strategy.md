<!-- markdownlint-disable MD013 -->

# Strategy

## Problem

Several algorithms or policies share one stable call shape.

## Direct Shape

```ts
if (plan === "free") price = 0;
else if (plan === "team") price = seats * 10;
else if (plan === "enterprise") price = quote.amount;
```

## Pattern Shape

```ts
interface PricingStrategy { price(account: Account): Money; }
const strategies: Record<Plan, PricingStrategy> = { free, team, enterprise };
const price = strategies[account.plan].price(account);
```

## Tests

- Each strategy satisfies the same contract.
- Selection maps every supported plan.
- Adding a strategy does not change pricing callers.

## Misuse Signals

- Only one algorithm exists.
- Direct conditional is clearer for two tiny stable cases.
- The implementation introduces more concepts than the requirement needs.
