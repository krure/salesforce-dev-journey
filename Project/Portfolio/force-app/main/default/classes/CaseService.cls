public class CaseService {

    public static void validateCases(List<Case> casesToValidate) {
        for (Case c : casesToValidate) {
            if (String.isBlank(c.Subject)) {
                c.addError('Case Subject is required.');
            }
        }
    }

    public static void validateStatusChange(
        List<Case> newCases,
        Map<Id, Case> oldMap
    ) {
        for (Case c : newCases) {
            Case oldCase = oldMap.get(c.Id);

            if (oldCase != null &&
                oldCase.Status == 'Closed' &&
                c.Status != 'Closed'
            ) {
                c.addError('Closed cases cannot be reopened.');
            }
        }
    }
}
