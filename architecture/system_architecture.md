# 🏗 System Architecture

```
                  Source Systems
        ┌────────────┬────────────┬────────────┐
        │            │            │
   Customer Orders  Forecast   Product Status
        │            │            │
        └────────────┴────────────┘
                     │
                     ▼
              PostgreSQL Database
                     │
             Advanced SQL Queries
                     │
             KPI Calculations
                     │
        Forecast Allocation Logic
                     │
      Product Deactivation Logic
                     │
                     ▼
            Metabase Dashboard
                     │
                     ▼
      Operations Team / Business Users
```

---

## Data Flow

1. Customer orders are stored in PostgreSQL.
2. Forecast data is collected daily.
3. Product availability and deactivation data are processed.
4. SQL transformations calculate operational KPIs.
5. Metabase visualizes the KPIs.
6. Operations teams monitor performance and make business decisions.

---

## Technologies Used

- PostgreSQL
- SQL
- Metabase
- GitHub
