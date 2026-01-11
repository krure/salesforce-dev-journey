# Functional & Technical Flow — Case Lifecycle

## 1. High-Level Flow Overview

This document describes the functional and technical flow for creating and managing service requests (Cases) through an Experience Cloud portal, including synchronization with an external system.

---

## 2. External User Flow (Experience Cloud)

1. External user logs into the Experience Cloud portal
2. User accesses the "My Requests" page
3. User creates a new Case using a custom Lightning Web Component (LWC)
4. The LWC performs basic client-side validation
5. The LWC calls an Apex controller to submit the Case

---

## 3. Apex Processing Flow

6. Apex Controller receives the request
7. Server-side validations are executed
8. Case record is inserted
9. A Trigger is executed on Case (after insert / after update)
10. Trigger delegates logic to a Trigger Handler
11. Trigger Handler calls a Service class responsible for integration logic

---

## 4. Integration Flow (PoC)

12. Service class evaluates whether a callout is required
13. REST callout is executed using Named Credentials
14. External system returns a response (success or error)
15. Response is parsed and processed
16. Integration result is logged in a custom object (Integration_Log__c)
17. Case record is updated with external reference data (if applicable)

---

## 5. Error Handling Strategy

- Callout errors are caught and logged
- Case record is not rolled back due to integration failure
- Integration status is stored for troubleshooting
- Retry strategy can be implemented using Queueable Apex (future enhancement)

---

## 6. Security and Access Control

- Portal users can only access their related Cases
- Apex enforces sharing rules
- Named Credentials handle authentication securely
- No credentials are hardcoded

---

## 7. Test Strategy

- Apex tests cover:
  - Case creation logic
  - Trigger handler execution
  - Integration callout using HttpCalloutMock
- Assertions validate both functional and integration outcomes

---

## 8. Future Enhancements (Out of MVP)

- Retry mechanism for failed integrations
- Platform Events for asynchronous processing
- Advanced error notifications
- Enhanced UI/UX
- Regular data cleanup activities and data remediation strategies.
