# `Wanda.Executions.Server`
[🔗](https://github.com/trento-project/wanda/blob/main/lib/wanda/executions/server.ex#L4)

Represents the execution of the CheckSelection(s) on the target nodes/agents of a cluster
Orchestrates facts gathering on the targets - issuing execution and receiving back facts - and following check evaluations.

# `child_spec`

Returns a specification to start this module under a supervisor.

See `Supervisor`.

# `start_execution`

Starts a check execution.

The checks are filtered leveraging the `env` and evaluating the `when` condition using a best-effort approach.
If non-existing check IDs are provided inside a target, they will get filtered away.

# `start_link`

---

*Consult [api-reference.md](api-reference.md) for complete listing*
