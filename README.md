# Dizen

> Pluggable object decorators

### Decorating

```dizen.decorate (obj, decorators, options)```

The `decorator` argument is very dynamic. It can be...

- a string representing the `decorator_name` of a registered decorator (see [dizen.use()]()).
- an array of strings representing registered `decorator_names` (again, [dizen.use()]())
- a decorating object, provided it adheres to the [decorator interface]().
- an array of objects containing decorators and optional [init options]().
  ```
  [{
    decorator: String or Object,
    options: Object
  }, // etc.
  ]
  ```