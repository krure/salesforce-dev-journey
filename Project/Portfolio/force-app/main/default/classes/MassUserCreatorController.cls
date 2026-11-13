/**
 * @description  Apex Controller for LWC massUserCreator.
 *               Returns profile, permission sets and provides user creation functions.
 * @author       Krure
 */
public with sharing class MassUserCreatorController {

    // ─────────────────────────────────────────────────────────────────────────
    // DTOs (wrappers para serializar a JSON hacia el LWC)
    // ─────────────────────────────────────────────────────────────────────────

    public class OptionWrapper {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        public OptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class UserInputWrapper {
        @AuraEnabled public String firstName      { get; set; }
        @AuraEnabled public String lastName       { get; set; }
        @AuraEnabled public String email          { get; set; }
        @AuraEnabled public String username       { get; set; }
        @AuraEnabled public String profileId      { get; set; }
        @AuraEnabled public String roleId         { get; set; }
        @AuraEnabled public List<String> permissionSetIds { get; set; }
    }

    public class UserResultWrapper {
        @AuraEnabled public Boolean success   { get; set; }
        @AuraEnabled public String  userId    { get; set; }
        @AuraEnabled public String  fullName  { get; set; }
        @AuraEnabled public String  email     { get; set; }
        @AuraEnabled public String  errorMessage { get; set; }

        public UserResultWrapper(Boolean success, String userId,
                                  String fullName, String email,
                                  String errorMessage) {
            this.success      = success;
            this.userId       = userId;
            this.fullName     = fullName;
            this.email        = email;
            this.errorMessage = errorMessage;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Query methods (cacheable)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * @description Returns all active profiles
     */
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getProfiles() {
        List<OptionWrapper> options = new List<OptionWrapper>();
        for (Profile p : [
            SELECT Id, Name
            FROM   Profile
            ORDER  BY Name ASC
            LIMIT  200
        ]) {
            options.add(new OptionWrapper(p.Name, p.Id));
        }
        return options;
    }

    /**
     * @description Returns all active roles
     */
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getUserRoles() {
        List<OptionWrapper> options = new List<OptionWrapper>();
        for (UserRole r : [
            SELECT Id, Name
            FROM   UserRole
            ORDER  BY Name ASC
            LIMIT  500
        ]) {
            options.add(new OptionWrapper(r.Name, r.Id));
        }
        return options;
    }

    /**
     * @description Returns all Permission set that dont require a license
     *               (IsOwnedByProfile = false).
     */
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getPermissionSets() {
        List<OptionWrapper> options = new List<OptionWrapper>();
        for (PermissionSet ps : [
            SELECT Id, Label
            FROM   PermissionSet
            WHERE  IsOwnedByProfile = false
            ORDER  BY Label ASC
            LIMIT  500
        ]) {
            options.add(new OptionWrapper(ps.Label, ps.Id));
        }
        return options;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Mass creation 
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * @description Create and assign all received users
     *              Uses Database.insert withj allOrNone = false to report
     *              by-row errors and prevent operation interruption
     *
     * @param  userInputs  List of UserInputWrapper with data from the form.
     * @return             List of UserResultWrapper with the user result.
     */
    @AuraEnabled
    public static List<UserResultWrapper> createUsers(
            List<UserInputWrapper> userInputs) {

        List<UserResultWrapper> results = new List<UserResultWrapper>();

        if (userInputs == null || userInputs.isEmpty()) {
            return results;
        }

        // 1. Construir objetos User
        List<User> usersToInsert = new List<User>();
        for (UserInputWrapper input : userInputs) {
            User u = new User(
                FirstName = input.firstName,
                LastName  = input.lastName,
                Email     = input.email,
                Username  = String.isNotBlank(input.username)
                                ? input.username
                                : input.email,
                Alias     = buildAlias(input.firstName, input.lastName),
                ProfileId = input.profileId,
                UserRoleId = String.isNotBlank(input.roleId)
                                ? input.roleId
                                : null,
               //Default values TODO: add these fields to be specified in the form
                TimeZoneSidKey    = 'America/Mexico_City',
                LocaleSidKey      = 'es_MX',
                EmailEncodingKey  = 'UTF-8',
                LanguageLocaleKey = 'es'
            );
            usersToInsert.add(u);
        }

        // 2. Add users (partial success)
        Database.SaveResult[] saveResults =
            Database.insert(usersToInsert, false);

        // 3. Process results and identify success
        //    Save index → PSIds for next step
                Map<Integer, List<String>> indexToPermSets = new Map<Integer, List<String>>();

        for (Integer i = 0; i < saveResults.size(); i++) {
            Database.SaveResult sr = saveResults[i];
            UserInputWrapper    inp = userInputs[i];
            String fullName = inp.firstName + ' ' + inp.lastName;

            if (sr.isSuccess()) {
                results.add(new UserResultWrapper(
                    true, sr.getId(), fullName, inp.email, null
                ));

                if (inp.permissionSetIds != null &&
                        !inp.permissionSetIds.isEmpty()) {
                    indexToPermSets.put(i, inp.permissionSetIds);
                }
            } else {
                String errorMsg = sr.getErrors()[0].getMessage();
                results.add(new UserResultWrapper(
                    false, null, fullName, inp.email, errorMsg
                ));
            }
        }

        // 4. Assign Permission Sets to the created users
        if (!indexToPermSets.isEmpty()) {
            List<PermissionSetAssignment> assignments =
                new List<PermissionSetAssignment>();

            for (Integer idx : indexToPermSets.keySet()) {
                String userId = usersToInsert[idx].Id;
                for (String psId : indexToPermSets.get(idx)) {
                    assignments.add(new PermissionSetAssignment(
                        AssigneeId    = userId,
                        PermissionSetId = psId
                    ));
                }
            }

            
            Database.insert(assignments, false);
        }

        return results;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers 
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * @description Alias generator
     */
    private static String buildAlias(String firstName, String lastName) {
        String base = '';
        if (String.isNotBlank(firstName)) {
            base += firstName.left(1);
        }
        if (String.isNotBlank(lastName)) {
            base += lastName.left(7);
        }
        return base.left(8).toLowerCase();
    }
}