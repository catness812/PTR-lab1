This repository contains the second laboratory work for the Real-Time Programming course:

## [Lab 1](Lab1)
| Weeks                | Progress           |
| :---:                | :---:              |
| Week 1               | :white_check_mark: |
| Week 2               | :white_check_mark: |
| Week 3               | :white_check_mark: |
| Week 4               | :on:               |
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
    A[Sup Sup] --> B[Reader 1];
    A[Sup Sup] --> C[Reader 2];
    A[Sup Sup] --> D[Printer];
    A[Sup Sup] --> E[Hashtag Printer];
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
    A[Sup Sup] --> B[Reader 1];
    A[Sup Sup] --> C[Reader 2];
    A[Sup Sup] --> D[Printer Supervisor];
    D[Printer Supervisor] --> E[Load Balancer];
    D[Printer Supervisor] --> F[Printer 1];
    D[Printer Supervisor] --> G[Printer 2];
    D[Printer Supervisor] --> H[Printer 3];
    D[Printer Supervisor] --> I[Hashtag Printer];
```

### Week 3

#### Message Flow

```mermaid
sequenceDiagram
Readers ->> Printer Supervisor: get tweets
Printer Supervisor ->> Load Balancer: acquire printer
Load Balancer -->> Printer Supervisor: return first 3 printer ids with the least prints
Load Balancer ->> Workers Manager: analyze the total nr of workers and prints
Workers Manager ->> Printer Supervisor: manage nr of workers
Printer Supervisor ->> Load Balancer: get id to either add or remove
Load Balancer -->> Printer Supervisor: return id
Printer Supervisor ->> Printers: send to first id received to print tweet
Printers ->> Load Balancer: release printer

Readers ->> Hashtag Printer: get and print hashtags
```

#### Supervision Tree

```mermaid
graph TD
    A[Sup Sup] --> B[Reader 1];
    A[Sup Sup] --> C[Reader 2];
    A[Sup Sup] --> D[Printer Supervisor];
    D[Printer Supervisor] --> E[Load Balancer];
    D[Printer Supervisor] --> F[Workers Manager];
    D[Printer Supervisor] --> G[Printers];
    D[Printer Supervisor] --> H[Hashtag Printer];
```
