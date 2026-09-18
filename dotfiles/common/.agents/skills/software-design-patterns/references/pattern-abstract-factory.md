<!-- markdownlint-disable MD013 -->

# Abstract Factory

## Problem

Families of related objects must be created together without mixing incompatible variants.

## Direct Shape

```ts
const button = new MacButton();
const dialog = new WindowsDialog();
render(button, dialog);
```

## Pattern Shape

```ts
interface WidgetFactory {
  button(): Button;
  dialog(): Dialog;
}

function renderSettings(factory: WidgetFactory) {
  render(factory.button(), factory.dialog());
}
```

## Tests

- Test each factory creates compatible products.
- Test the caller never mixes products from different families.

## Misuse Signals

- Only one product type exists.
- A simple factory function would select one object clearly.
- The implementation introduces more concepts than the requirement needs.
