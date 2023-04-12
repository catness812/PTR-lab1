This repository contains the second laboratory work for the Real-Time Programming course:

## [Lab 1](Lab1)
| Weeks                | Progress           |
| :---:                | :---:              |
| Week 1               | :white_check_mark: |
| Week 2               | :white_check_mark: |
| Week 3               | :white_check_mark: |
| Week 4               | :white_check_mark: |
| Week 5               | :white_check_mark: |
| Week 6               | :white_check_mark: |

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

### Week 4

#### Message Flow

```mermaid
sequenceDiagram
Readers ->> Stream Processor Supervisor: get tweets
Stream Processor Supervisor ->> Printer Supervisors: send to print tweets by pid
Printer Supervisors ->> Load Balancers: acquire printer
Load Balancers -->> Printer Supervisors: return first 3 printer ids with the least prints
Load Balancers ->> Workers Managers: analyze the total nr of workers and prints
Workers Managers ->> Printer Supervisors: manage nr of workers
Printer Supervisors ->> Load Balancers: get id to either add or remove
Load Balancers -->> Printer Supervisors: return id
Printer Supervisors ->> Printers: send to first id received to print tweet
Printers ->> Tweet Redacters: filter tweet
Tweet Redacters -->> Printers: receive filtered tweet
Printers ->> Sentiment Score Calculators: compute sentiment score
Sentiment Score Calculator -->> Printers: receive sentiment score
Printers ->> Engagement Ratio Calculators: compute engagement ratio per tweet
Engagement Ratio Calculator -->> Printers: receive engagement ratio
Printers ->> Load Balancer: release printer

Readers ->> Hashtag Printer: get and print hashtags
Readers ->> User Engagement Ratio Calculator: get and print hashtags
```

#### Supervision Tree

```mermaid
graph TD
    A[Stream Processor Supervisor] --> B[Reader 1];
    A[Stream Processor Supervisor] --> C[Reader 2];
    A[Stream Processor Supervisor] --> D[Printer Supervisors];
    A[Stream Processor Supervisor] --> H[Hashtag Printer];
    A[Stream Processor Supervisor] --> I[User Engagement Ratio Calculator];
    D[Printer Supervisors] --> E[Load Balancers];
    D[Printer Supervisors] --> F[Workers Managers];
    D[Printer Supervisors] --> G[Printers];
    D[Printer Supervisors] --> J[Tweet Redacters];
    D[Printer Supervisors] --> K[Sentiment Score Calculators];
    D[Printer Supervisors] --> L[Engagement Ratio Calculators];
```

### Week 5

#### Message Flow

```mermaid
sequenceDiagram
Readers ->> Stream Processor Supervisor: get tweets
Stream Processor Supervisor ->> Printer Supervisors: send to print tweets by pid
Printer Supervisors ->> Load Balancers: acquire printer
Load Balancers -->> Printer Supervisors: return first 3 printer ids with the least prints
Load Balancers ->> Workers Managers: analyze the total nr of workers and prints
Workers Managers ->> Printer Supervisors: manage nr of workers
Printer Supervisors ->> Load Balancers: get id to either add or remove
Load Balancers -->> Printer Supervisors: return id
Printer Supervisors ->> Printers: send to first id received to print tweet
Printers ->> Tweet Redacters: filter tweet
Tweet Redacters ->> Aggregators: collect filtered tweet
Printers ->> Sentiment Score Calculators: compute sentiment score
Sentiment Score Calculators ->> Aggregators: collect sentiment score
Printers ->> Engagement Ratio Calculators: compute engagement ratio per tweet
Engagement Ratio Calculators ->> Aggregators: collect engagement ratio per tweet
Batchers ->> Aggregators: request data
Aggregators -->> Batchers: respond with data
Printers ->> Load Balancer: release printer

Readers ->> Hashtag Printer: get and print hashtags
Readers ->> User Engagement Ratio Calculator: get and print hashtags
```

#### Supervision Tree

```mermaid
graph TD
    A[Stream Processor Supervisor] --> B[Reader 1];
    A[Stream Processor Supervisor] --> C[Reader 2];
    A[Stream Processor Supervisor] --> D[Printer Supervisors];
    A[Stream Processor Supervisor] --> H[Hashtag Printer];
    A[Stream Processor Supervisor] --> I[User Engagement Ratio Calculator];
    D[Printer Supervisors] --> E[Load Balancers];
    D[Printer Supervisors] --> F[Workers Managers];
    D[Printer Supervisors] --> G[Printers];
    D[Printer Supervisors] --> J[Tweet Redacters];
    D[Printer Supervisors] --> K[Sentiment Score Calculators];
    D[Printer Supervisors] --> L[Engagement Ratio Calculators];
    D[Printer Supervisors] --> M[Aggregators];
    D[Printer Supervisors] --> N[Batchers];
```

### Week 6

#### Message Flow

```mermaid
sequenceDiagram
Readers ->> Stream Processor Supervisor: get tweets
Stream Processor Supervisor ->> Printer Supervisors: send to print tweets by pid
Printer Supervisors ->> Load Balancers: acquire printer
Load Balancers -->> Printer Supervisors: return first 3 printer ids with the least prints
Load Balancers ->> Workers Managers: analyze the total nr of workers and prints
Workers Managers ->> Printer Supervisors: manage nr of workers
Printer Supervisors ->> Load Balancers: get id to either add or remove
Load Balancers -->> Printer Supervisors: return id
Printer Supervisors ->> Printers: send to first id received to print tweet
Printers ->> Tweet Redacters: filter tweet
Tweet Redacters ->> Aggregators: collect filtered tweet
Printers ->> Sentiment Score Calculators: compute sentiment score
Sentiment Score Calculators ->> Aggregators: collect sentiment score
Printers ->> Engagement Ratio Calculators: compute engagement ratio per tweet
Engagement Ratio Calculators ->> Aggregators: collect engagement ratio per tweet
Batchers ->> Aggregators: request data
Aggregators -->> Batchers: respond with data
Batchers ->> Database: store data
Printers ->> Load Balancer: release printer

Readers ->> Hashtag Printer: get and print hashtags
Readers ->> User Engagement Ratio Calculator: get and print hashtags
```

#### Supervision Tree

```mermaid
graph TD
    A[Stream Processor Supervisor] --> B[Reader 1];
    A[Stream Processor Supervisor] --> C[Reader 2];
    A[Stream Processor Supervisor] --> D[Printer Supervisors];
    A[Stream Processor Supervisor] --> H[Hashtag Printer];
    A[Stream Processor Supervisor] --> I[User Engagement Ratio Calculator];
    D[Printer Supervisors] --> E[Load Balancers];
    D[Printer Supervisors] --> F[Workers Managers];
    D[Printer Supervisors] --> G[Printers];
    D[Printer Supervisors] --> J[Tweet Redacters];
    D[Printer Supervisors] --> K[Sentiment Score Calculators];
    D[Printer Supervisors] --> L[Engagement Ratio Calculators];
    D[Printer Supervisors] --> M[Aggregators];
    D[Printer Supervisors] --> N[Batchers];
```
