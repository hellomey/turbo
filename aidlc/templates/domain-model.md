# Domain model: U-<name>

Status: draft · approved (G-D by architect[, founder for T2])

## Ubiquitous language
Terms exactly as the app uses them (blueprint §3). One line each.

## Aggregates and entities
| Aggregate | Entities / value objects | Owning module | Table(s) |
|---|---|---|---|

## Invariants (must always hold; each becomes a unit test)
1. …

## State machines
```
state A --event--> state B   (guard)
```

## Domain events
| Event | Published when | Payload | Consumed by |
|---|---|---|---|

## Rules that touch the money/game firewall (T2)
Which FW-xxx tests cover them; which new FW-xxx tests this unit adds.

## Open questions
