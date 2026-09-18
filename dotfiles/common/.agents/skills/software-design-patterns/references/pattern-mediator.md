<!-- markdownlint-disable MD013 -->

# Mediator

## Problem

Several components coordinate by calling each other directly, creating a tangled graph.

## Direct Shape

```ts
field.onChange = () => { button.enabled = field.valid; panel.refresh(); logger.record(); };
```

## Pattern Shape

```ts
class FormMediator {
  fieldChanged(field: Field) {
    button.enabled = field.valid;
    panel.refresh();
    logger.record("field-changed");
  }
}
```

## Tests

- Peer components no longer know each other directly.
- Mediator coordination rules are tested.

## Misuse Signals

- Mediator becomes a god object.
- Direct parent-child communication is simpler.
- The implementation introduces more concepts than the requirement needs.
