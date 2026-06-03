# `Wanda.Catalog.Check`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/catalog/check.ex#L4)

Represents a check.

# `t`

```elixir
@type t() :: %Wanda.Catalog.Check{
  customization_disabled: boolean(),
  description: String.t(),
  expectations: [Wanda.Catalog.Expectation.t()],
  facts: [Wanda.Catalog.Fact.t()],
  group: String.t(),
  id: String.t(),
  metadata: map(),
  name: String.t(),
  remediation: String.t(),
  severity: Wanda.Catalog.Enums.Severity.t(),
  values: [Wanda.Catalog.Value.t()],
  when: String.t()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*
