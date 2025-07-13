# Financial Data Analysis with SQL & Tableau

This project explores a real-world financial dataset using advanced SQL techniques and presents key insights through interactive Tableau dashboards.

## 📌 Dataset

The dataset comes from the [PKDD'99 Financial Dataset](https://relational.fit.cvut.cz/dataset/Financial), which includes:

- 1 million+ transactions
- 8 interlinked tables (`loan`, `account`, `client`, `trans`, etc.)
- Real-world temporal and relational structure

> Data was accessed via a public MariaDB server and exported using DBeaver.

## 🛠️ Tech Stack

- **SQL (MariaDB)** – Data wrangling, joining, aggregating, and analytical queries
- **DBeaver** – SQL client used for connecting and exporting large tables
- **SQL Server (SSMS)** – For importing, transforming, and indexing the data
- **Tableau** – To build and publish interactive dashboards

## 📊 Goals

- Perform an in-depth analysis of customer and loan behavior
- Identify key patterns and anomalies in transactional data
- Visualize insights using Tableau
- Showcase query optimization techniques on a large-scale dataset

## 🚧 Work in Progress

- [x] Extracted and imported 8 financial tables
- [ ] Data wrangling and schema mapping
- [ ] Define analysis questions (customer lifetime, loan risk, account activity...)
- [ ] Build Tableau dashboard(s)
- [ ] Finalize README and documentation

## 📁 Project Structure

```
.
├── data/                   # CSV exports from MariaDB
├── sql/                    # SQL scripts (schema, queries, transformations)
├── tableau/                # Packaged Tableau workbook (.twb or .twbx)
├── reports/                # Optional: exported visuals or insights
└── README.md
```

## 📈 Sample Questions (TBD)

- Which clients are most active based on transaction volume?
- Is there a relationship between account balance patterns and loan repayment status?
- How does district-level data affect financial behavior?

## 🧠 Lessons Learned

> To be updated as the project progresses.

---

Stay tuned for the full dashboard and SQL deep dive!
