/**
 * @description Data Transfer Object (DTO) for error log information.
 * Encapsulates all error details before creating Error_Log__c records.
 * @author Portfolio DevOrg
 * @date 2026
 */
public class ErrorLogWrapper {
    
    /** @description Type of error (Integration, DML, Callout, etc.) */
    public String errorType { get; set; }
    
    /** @description Severity level (Critical, High, Medium, Low, Info) */
    public String severity { get; set; }
    
    /** @description Source Apex class name */
    public String sourceClass { get; set; }
    
    /** @description Source method name */
    public String sourceMethod { get; set; }
    
    /** @description Error message text */
    public String errorMessage { get; set; }
    
    /** @description Full stack trace */
    public String stackTrace { get; set; }
    
    /** @description Related Salesforce record ID */
    public String recordId { get; set; }
    
    /** @description User who triggered the error */
    public Id userId { get; set; }
    
    /** @description Integration endpoint URL */
    public String integrationEndpoint { get; set; }
    
    /** @description HTTP request payload */
    public String requestPayload { get; set; }
    
    /** @description HTTP response payload */
    public String responsePayload { get; set; }
    
    /** @description HTTP status code */
    public Integer statusCode { get; set; }
    
    /** @description Number of retry attempts */
    public Integer retryCount { get; set; }
    
    /**
     * @description Default constructor
     */
    public ErrorLogWrapper() {
        this.retryCount = 0;
    }
    
    /**
     * @description Constructor with basic error information
     * @param errorType The error type
     * @param severity The severity level
     * @param sourceClass The source class name
     * @param sourceMethod The source method name
     * @param errorMessage The error message
     */
    public ErrorLogWrapper(
        String errorType,
        String severity,
        String sourceClass,
        String sourceMethod,
        String errorMessage
    ) {
        this.errorType = errorType;
        this.severity = severity;
        this.sourceClass = sourceClass;
        this.sourceMethod = sourceMethod;
        this.errorMessage = errorMessage;
        this.userId = UserInfo.getUserId();
        this.retryCount = 0;
    }
}