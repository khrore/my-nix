<!-- markdownlint-disable MD013 -->

# Visitor

## Problem

Many operations must run over a stable object structure without adding methods to every node each time.

## Direct Shape

```ts
function render(node: Node) {
  if (node.kind === "text") return renderText(node);
  if (node.kind === "image") return renderImage(node);
}
```

## Pattern Shape

```ts
interface NodeVisitor<R> { visitText(node: TextNode): R; visitImage(node: ImageNode): R; }
interface Node { accept<R>(visitor: NodeVisitor<R>): R; }
```

## Tests

- Every node calls the matching visitor method.
- Each visitor operation covers all node types.
- Adding a node reveals missing visitor methods.

## Misuse Signals

- Node types change frequently.
- A simple pattern match is clearer in the language.
- The implementation introduces more concepts than the requirement needs.
