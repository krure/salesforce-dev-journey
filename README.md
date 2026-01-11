# salesforce-dev-journey
A repository to develop and document my personal SF projects

Featuring (MVPs):
  - A self-service portal where customers create and query their requests, with managed sinchronization towards an external system.
    - Portal (Experience Cloud)
      - User Login
      - Screens:
        - Case creation
        - Case list
        - Status check
    - Case management
      - Case creation from portal
      - Managed statuses
      - Basic Apex validations
    - Integrations
      - On case creation or update:
        - REST call to an external system (mock)}
        - Error handling
        - Basic logging
    - Technical implementations
      - THP (Trigger Handler Pattern)
      - Testing (LWC and Apex test classes)
      - Named credentials
