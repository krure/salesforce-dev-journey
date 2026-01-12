#View in Code form

+-------------------+
|   External User   |
| (Customer/Partner)|
+---------+---------+
          |
          | Login / Interaction
          v
+-------------------+
| Experience Cloud  |
|     Portal        |
+---------+---------+
          |
          | Create / View Case
          v
+-------------------+
|   LWC Components  |
|-------------------|
| - Client-side     |
|   validation      |
| - UI interaction |
+---------+---------+
          |
          | Apex Method Call
          v
+---------------------------+
|     Apex Controller       |
|---------------------------|
| - Server-side validation  |
| - Business rules          |
+-------------+-------------+
              |
              | DML (Insert/Update)
              v
+---------------------------+
|       Case Trigger        |
+-------------+-------------+
              |
              | Delegate logic
              v
+---------------------------+
|    Trigger Handler        |
+-------------+-------------+
              |
              | Invoke integration logic
              v
+---------------------------+
|   Integration Service     |
|---------------------------|
| - REST Callout            |
| - Error handling          |
| - Response parsing        |
+-------------+-------------+
              |
              | Named Credential
              v
+---------------------------+
|   External System (PoC)   |
|---------------------------|
| - Receives Case data      |
| - Returns status / ID     |
+-------------+-------------+
              |
              | Response
              v
+---------------------------+
| Integration_Log__c        |
|---------------------------|
| - Request / Response      |
| - Status / Timestamp      |
+---------------------------+

