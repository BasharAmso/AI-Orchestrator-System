# Diagrams

> Visual representations of Bashi architecture. Rendered using Mermaid syntax.

---

## The Dispatch Chain

How the system routes work from events to execution:

```mermaid
flowchart TD
    A["/run-project"] --> B{Unprocessed Events?}
    B -->|Yes| C[Select oldest event - FIFO]
    B -->|No| D{Active Task?}
    D -->|Yes| E[Resume active task]
    D -->|No| F{Tasks in queue?}
    F -->|Yes| G[Promote next task]
    F -->|No| H[Phase-Aware Guidance]

    C --> I{Skill match in REGISTRY?}
    E --> I
    G --> I

    I -->|Yes| J[Execute Skill]
    I -->|No| K{Event hook match?}
    K -->|Yes| J
    K -->|No| L{Routing rule match?}
    L -->|Yes| J
    L -->|No| M[Orchestrator handles directly]

    J --> N[Update STATE.md]
    M --> N
    N --> O{Stop condition met?}
    O -->|Yes| P[Print Run Summary]
    O -->|No| Q{More cycles allowed?}
    Q -->|Yes| B
    Q -->|No| P
```

---

## Project Lifecycle

The phases a project moves through:

```mermaid
flowchart LR
    NS[Not Started] --> PL[Planning]
    PL --> BU[Building]
    BU --> RD[Ready for Deploy]
    RD --> DE[Deploying]
    DE --> LI[Live]

    style NS fill:#f0f0f0,stroke:#999
    style PL fill:#fff3cd,stroke:#ffc107
    style BU fill:#cce5ff,stroke:#0d6efd
    style RD fill:#d1ecf1,stroke:#0dcaf0
    style DE fill:#f8d7da,stroke:#dc3545
    style LI fill:#d4edda,stroke:#198754
```

---

## The Orchestration Stack

How the framework layers are organized:

```mermaid
flowchart TB
    subgraph User Layer
        A[User Idea / Goal]
    end

    subgraph Command Layer
        B["/start  /setup  /capture-idea  /run-project"]
    end

    subgraph Orchestrator Layer
        C[Orchestrator Agent]
    end

    subgraph Skill Layer
        D["Skills (26 reusable workflows)"]
    end

    subgraph Agent Layer
        E["Agents (Builder, Reviewer, Fixer, Deployer, ...)"]
    end

    subgraph State Layer
        F["STATE.md  |  EVENTS.md  |  REGISTRY.md"]
    end

    subgraph Knowledge Layer
        G["Decisions  |  Research  |  Glossary  |  Open Questions"]
    end

    subgraph Memory Layer
        H["AI-Memory (cross-project learning)"]
    end

    A --> B --> C
    C --> D --> E
    C <--> F
    C <--> G
    C <--> H
```

---

## Run Modes

How the three execution modes compare:

```mermaid
flowchart LR
    subgraph Safe Mode
        S1[Propose action] --> S2[Stop]
    end

    subgraph Semi-Autonomous
        SA1[Execute 1 cycle] --> SA2[Stop for review]
    end

    subgraph Autonomous
        AU1[Execute cycle 1] --> AU2[Check stop conditions]
        AU2 -->|Continue| AU3[Execute cycle 2]
        AU3 --> AU4[...]
        AU4 --> AU5[Execute cycle N]
        AU5 --> AU6[Stop at limit or condition]
    end
```
