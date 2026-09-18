<!-- markdownlint-disable MD013 -->

# Composite

## Problem

Single objects and groups of objects should be treated through the same contract.

## Direct Shape

```ts
function price(node: MenuNode): number {
  if (node.type === "item") return node.price;
  return node.children.reduce((sum, child) => sum + price(child), 0);
}
```

## Pattern Shape

```ts
interface Priced { price(): number; }
class MenuItem implements Priced { price() { return this.amount; } }
class MenuBundle implements Priced { price() { return this.children.reduce((s, c) => s + c.price(), 0); } }
```

## Tests

- Leaf and composite obey the same contract.
- Nested composites produce expected aggregate results.

## Misuse Signals

- The structure is not tree-like.
- The common interface hides operations only valid for branches.
- The implementation introduces more concepts than the requirement needs.
