# MVP Scope — Customer Engagement & Case Management Platform

## 1. Business Problem

B2B companies often lack a clear and unified way for customers or partners to track the status of their service requests.
This results in:
- Increased manual follow-ups (emails, calls)
- Limited visibility for customers
- Operational inefficiencies for support teams
- Data inconsistency across systems

The goal of this MVP is to demonstrate how Salesforce can act as a central platform to manage customer service requests while integrating with external systems.

---

## 2. Target Users

- External Users (Customers / Partners)
  - Access via Experience Cloud
  - Create and track service requests

- Internal Users (Support Agents)
  - Manage and update cases in Salesforce
  - Monitor integration status

---

## 3. MVP Objectives

- Provide a self-service portal for external users
- Enable controlled case creation and tracking
- Synchronize case data with an external system (PoC)
- Demonstrate scalable and maintainable Salesforce development practices

---

## 4. In-Scope Functionality

### 4.1 Experience Cloud Portal
- User authentication
- Create a Case via custom LWC
- View list of related Cases
- View Case status and key fields

### 4.2 Case Management
- Case creation and updates handled via Apex
- Basic business validations
- Controlled Case status transitions

### 4.3 Integration (Proof of Concept)
- REST callout to an external system when a Case is created or updated
- Use of Named Credentials for authentication
- Error handling and logging
- Test coverage using HttpCalloutMock

### 4.4 Technical Quality
- Trigger Handler Pattern
- Service layer separation
- Apex test coverage >80%
- Meaningful assertions in tests

---

## 5. Out of Scope

- Advanced reporting and dashboards
- Omni-Channel or Live Chat
- Mobile optimization
- Complex UI/UX customization
- SOAP-based integrations

---

## 6. Assumptions and Constraints

- External system is simulated (mocked) for demonstration purposes
- MVP focuses on functionality and architecture, not visual design
- Data volume is limited for development and testing

---

## 7. Success Criteria

The MVP is considered successful if:
- An external user can create and view a Case through the portal
- Case data is successfully sent to the external system
- Errors are handled gracefully and logged
- The solution is easy to understand, extend, and maintain
