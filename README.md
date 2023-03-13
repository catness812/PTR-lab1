This repository contains the second laboratory work for the Real-Time Programming course:

## [Lab 1](Lab1)
| Weeks                | Progress           |
| :---:                | :---:              |
| Week 1               | :white_check_mark: |
| Week 2               | :white_check_mark: |
| Week 3               | :on:               |
| Week 4               | :soon:             |
| Week 5               | :soon:             |


## Diagrams

### Week 1

#### Message Flow

```mermaid
sequenceDiagram
Readers ->> Printer: get and print tweets
Readers ->> Hashtag Printer: get and print hashtags
```

#### Supervision Tree

```mermaid
graph TD 
    A[Supervisor] --> B[Reader 1];
    A[Supervisor] --> C[Reader 2];
    A[Supervisor] --> D[Printer];
    A[Supervisor] --> E[Hashtag Printer];
```

### Week 2

#### Message Flow

```mermaid
sequenceDiagram
Readers ->> Printer Supervisor: get tweets
Printer Supervisor ->> Load Balancer: acquire printer
Load Balancer -->> Printer Supervisor: return printer id
Printer Supervisor ->> Printers: print tweets
Printers ->> Load Balancer: release printer

Readers ->> Hashtag Printer: get and print hashtags
```

#### Supervision Tree

```mermaid
graph TD 
    A[Reader 1];
    B[Reader 2];
    C[Printer Supervisor] --> E[Load Balancer];
    C[Printer Supervisor] --> F[Printer 1];
    C[Printer Supervisor] --> G[Printer 2];
    C[Printer Supervisor] --> H[Printer 3];
    C[Printer Supervisor] --> I[Hashtag Printer];
```
