/**
 * @description Service class for creating and managing error logs throughout the Salesforce org.
 * Provides centralized error logging for exceptions, integrations, DML operations, and batch jobs.
 * @author Portfolio DevOrg
 * @date 2026
 */
public with sharing class ErrorLogService {
    
    /**
     * @description Logs a generic exception with source class and method information
     * @param ex The exception to log
     * @param sourceClass The class name where the exception occurred
     * @param sourceMethod The method name where the exception occurred
     * @return The created Error_Log__c record ID
     * @example
     * try {
     *     // risky operation
     * } catch (Exception e) {
     *     ErrorLogService.logException(e, 'MyClass', 'myMethod');
     * }
     */
    public static Id logException(Exception ex, String sourceClass, String sourceMethod) {
        return logException(ex, sourceClass, sourceMethod, null, null);
    }
    
    /**
     * @description Logs an exception with additional context (record ID and severity)
     * @param ex The exception to log
     * @param sourceClass The class name where the exception occurred
     * @param sourceMethod The method name where the exception occurred
     * @param recordId The related record ID (optional)
     * @param severity The error severity level (optional, defaults to 'Medium')
     * @return The created Error_Log__c record ID
     */
    public static Id logException(
        Exception ex, 
        String sourceClass, 
        String sourceMethod, 
        String recordId, 
        String severity
    ) {
        if (ex == null) {
            return null;
        }
        
        ErrorLogWrapper wrapper = new ErrorLogWrapper();
        wrapper.errorType = determineErrorType(ex);
        wrapper.severity = String.isBlank(severity) ? 'Medium' : severity;
        wrapper.sourceClass = sourceClass;
        wrapper.sourceMethod = sourceMethod;
        wrapper.errorMessage = ex.getMessage();
        wrapper.stackTrace = ex.getStackTraceString();
        wrapper.recordId = recordId;
        wrapper.userId = UserInfo.getUserId();
        
        return createErrorLog(wrapper);
    }
    
    /**
     * @description Logs an HTTP integration error with request/response payloads
     * @param response The HTTP response object
     * @param endpoint The endpoint URL that was called
     * @param requestPayload The request body sent
     * @param sourceClass The class name making the callout
     * @param sourceMethod The method name making the callout
     * @return The created Error_Log__c record ID
     * @example
     * HttpResponse res = http.send(req);
     * if (res.getStatusCode() != 200) {
     *     ErrorLogService.logIntegrationError(res, endpoint, payload, 'IntegrationService', 'syncData');
     * }
     */
    public static Id logIntegrationError(
        HttpResponse response,
        String endpoint,
        String requestPayload,
        String sourceClass,
        String sourceMethod
    ) {
        if (response == null) {
            return null;
        }
        
        ErrorLogWrapper wrapper = new ErrorLogWrapper();
        wrapper.errorType = 'Integration';
        wrapper.severity = response.getStatusCode() >= 500 ? 'High' : 'Medium';
        wrapper.sourceClass = sourceClass;
        wrapper.sourceMethod = sourceMethod;
        wrapper.errorMessage = 'HTTP ' + response.getStatusCode() + ': ' + response.getStatus();
        wrapper.integrationEndpoint = endpoint;
        wrapper.requestPayload = requestPayload;
        wrapper.responsePayload = response.getBody();
        wrapper.statusCode = response.getStatusCode();
        wrapper.userId = UserInfo.getUserId();
        
        return createErrorLog(wrapper);
    }
    
    /**
     * @description Logs DML operation errors with affected record information
     * @param dmlEx The DML exception
     * @param affectedRecordIds List of record IDs involved in the DML operation
     * @param sourceClass The class name performing DML
     * @param sourceMethod The method name performing DML
     * @return List of created Error_Log__c record IDs
     * @example
     * try {
     *     update accounts;
     * } catch (DmlException e) {
     *     ErrorLogService.logDmlError(e, accountIds, 'AccountService', 'updateRecords');
     * }
     */
    public static List<Id> logDmlError(
        DmlException dmlEx,
        List<Id> affectedRecordIds,
        String sourceClass,
        String sourceMethod
    ) {
        if (dmlEx == null || affectedRecordIds == null || affectedRecordIds.isEmpty()) {
            return new List<Id>();
        }
        
        List<ErrorLogWrapper> wrappers = new List<ErrorLogWrapper>();
        
        for (Integer i = 0; i < dmlEx.getNumDml(); i++) {
            ErrorLogWrapper wrapper = new ErrorLogWrapper();
            wrapper.errorType = 'DML';
            wrapper.severity = 'High';
            wrapper.sourceClass = sourceClass;
            wrapper.sourceMethod = sourceMethod;
            wrapper.errorMessage = dmlEx.getDmlMessage(i);
            wrapper.stackTrace = dmlEx.getStackTraceString();
            
            // Get the specific record ID from the DML index
            Integer dmlIndex = dmlEx.getDmlIndex(i);
            if (dmlIndex < affectedRecordIds.size()) {
                wrapper.recordId = affectedRecordIds[dmlIndex];
            }
            
            wrapper.userId = UserInfo.getUserId();
            wrappers.add(wrapper);
        }
        
        return createErrorLogs(wrappers);
    }
    
    /**
     * @description Logs batch job errors with batch context
     * @param ex The exception from the batch job
     * @param batchJobId The batch job ID
     * @param failedRecordIds List of record IDs that failed processing
     * @param sourceClass The batch class name
     * @return The created Error_Log__c record ID
     */
    public static Id logBatchError(
        Exception ex,
        Id batchJobId,
        List<Id> failedRecordIds,
        String sourceClass
    ) {
        if (ex == null) {
            return null;
        }
        
        ErrorLogWrapper wrapper = new ErrorLogWrapper();
        wrapper.errorType = 'Batch';
        wrapper.severity = 'High';
        wrapper.sourceClass = sourceClass;
        wrapper.sourceMethod = 'execute';
        wrapper.errorMessage = ex.getMessage();
        wrapper.stackTrace = ex.getStackTraceString();
        wrapper.recordId = batchJobId;
        wrapper.userId = UserInfo.getUserId();
        
        // Add failed record count to message
        if (failedRecordIds != null && !failedRecordIds.isEmpty()) {
            wrapper.errorMessage += ' | Failed Records: ' + failedRecordIds.size();
        }
        
        return createErrorLog(wrapper);
    }
    
    /**
     * @description Creates a single error log record from a wrapper
     * @param wrapper The ErrorLogWrapper containing error details
     * @return The created Error_Log__c record ID
     */
    public static Id createErrorLog(ErrorLogWrapper wrapper) {
        if (wrapper == null) {
            return null;
        }
        
        List<Id> ids = createErrorLogs(new List<ErrorLogWrapper>{ wrapper });
        return ids.isEmpty() ? null : ids[0];
    }
    
    /**
     * @description Creates multiple error log records from wrappers (bulk operation)
     * @param wrappers List of ErrorLogWrapper objects
     * @return List of created Error_Log__c record IDs
     */
    public static List<Id> createErrorLogs(List<ErrorLogWrapper> wrappers) {
        if (wrappers == null || wrappers.isEmpty()) {
            return new List<Id>();
        }
        
        List<Error_Log__c> errorLogs = new List<Error_Log__c>();
        
        for (ErrorLogWrapper wrapper : wrappers) {
            Error_Log__c log = new Error_Log__c();
            log.Error_Type__c = wrapper.errorType;
            log.Severity__c = wrapper.severity;
            log.Source_Class__c = truncate(wrapper.sourceClass, 255);
            log.Source_Method__c = truncate(wrapper.sourceMethod, 255);
            log.Error_Message__c = truncate(wrapper.errorMessage, 32768);
            log.Stack_Trace__c = truncate(wrapper.stackTrace, 32768);
            log.Record_Id__c = wrapper.recordId;
            log.User__c = wrapper.userId;
            log.Integration_Endpoint__c = wrapper.integrationEndpoint;
            log.Request_Payload__c = truncate(wrapper.requestPayload, 32768);
            log.Response_Payload__c = truncate(wrapper.responsePayload, 32768);
            log.Status_Code__c = wrapper.statusCode;
            log.Retry_Count__c = wrapper.retryCount != null ? wrapper.retryCount : 0;
            log.Is_Resolved__c = false;
            
            errorLogs.add(log);
        }
        
        List<Id> createdIds = new List<Id>();
        
        try {
            Database.SaveResult[] results = Database.insert(errorLogs, false);
            
            for (Database.SaveResult result : results) {
                if (result.isSuccess()) {
                    createdIds.add(result.getId());
                }
            }
        } catch (Exception ex) {
            // If error logging itself fails, write to debug logs as last resort
            System.debug(LoggingLevel.ERROR, 'Failed to create error logs: ' + ex.getMessage());
        }
        
        return createdIds;
    }
    
    /**
     * @description Determines the error type based on exception class name
     * @param ex The exception to analyze
     * @return The error type string
     */
    private static String determineErrorType(Exception ex) {
        String exceptionType = ex.getTypeName();
        
        if (exceptionType.contains('DmlException')) {
            return 'DML';
        } else if (exceptionType.contains('CalloutException')) {
            return 'Callout';
        } else if (exceptionType.contains('QueryException')) {
            return 'System';
        } else {
            return 'Other';
        }
    }
    
    /**
     * @description Truncates a string to the specified max length
     * @param value The string to truncate
     * @param maxLength The maximum length
     * @return The truncated string
     */
    private static String truncate(String value, Integer maxLength) {
        if (String.isBlank(value)) {
            return value;
        }
        return value.length() > maxLength ? value.substring(0, maxLength) : value;
    }
}