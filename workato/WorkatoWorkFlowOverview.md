# Workato Automation Layer

This folder contains redacted exports of SYNaTRA's core automation recipes (Skills).  
Each recipe orchestrates data retrieval and transformation across Salesforce, Jira, and Snowflake.

## Workato Workflow
![Workato Workflow](./diagrams/workatoWorkflow.svg)
---
## [Search for Account Id with Account Name](./recipes/SearchforAccountIdwithName.md)
If an account name is provided for the customer associated otherwise this step is skipped. Search part or all of the customer name to retrieve an account id to proceed in the following searches.

## [Getting Customer's Current Contract Information](./recipes/GetttingCasesRelatedtoCustomer.md)
Contract information provides the contact information and active subscriptions.

## Getting Cases Related to Customer
Using the provided customer identifier search Salesforce for cases relating to the account.

## Search Cases for Keywords
Using keywords from the issue description.

## Search Tickets for Keywords
Using keywords from the issue description.

---

## Recipe: syntra_customer_profile

**Purpose**  
Retrieves a structured view of the customer from Salesforce, Jira, and Snowflake.

**Actions**
- Query active subscriptions (SOQL)
- Retrieve recent Jira tickets (JQL)
- Retrieve case performance metrics (Snowflake SQL)
- Normalize and store results as a temporary data pill for downstream use

---

## __SYN__*a*__TRA__'s resolutionsummary

**Purpose**  
Generates a summarized narrative of the customer’s informationa d case history.

**Actions**
- Collate retrieved data from previous recipes
- Apply text summarization logic (Workato Job Description)
- Push output into chat

---

## Security and Redaction

All recipe exports in this directory have been redacted to remove:
- Org identifiers
- Connection names
- Endpoints
- Tokens or credentials
- Customer metadata

Each JSON export retains its step sequence and field mapping for transparency and review.

