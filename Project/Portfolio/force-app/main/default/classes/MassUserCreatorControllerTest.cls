/**
 * @description  Clase de prueba para MassUserCreatorController.
 *               Cobertura objetivo: >= 85 %
 */
@IsTest
private class MassUserCreatorControllerTest {

    // ── Fixture ───────────────────────────────────────────────────────────────

    /**
     * Devuelve el Id del primer perfil "Standard User" (o cualquier perfil
     * disponible en el sandbox/scratch org de prueba).
     */
    private static Id getTestProfileId() {
        return [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
    }

    // ── Tests de consulta ─────────────────────────────────────────────────────

    @IsTest
    static void testGetProfiles() {
        Test.startTest();
        List<MassUserCreatorController.OptionWrapper> result =
            MassUserCreatorController.getProfiles();
        Test.stopTest();

        System.assertNotEquals(0, result.size(),
            'Debe haber al menos un perfil en la org.');
        System.assertNotEquals(null, result[0].label, 'Label no debe ser nulo.');
        System.assertNotEquals(null, result[0].value, 'Value no debe ser nulo.');
    }

    @IsTest
    static void testGetUserRoles() {
        // Crear un rol para garantizar al menos uno en sandbox limpio
        UserRole role = new UserRole(Name = 'Test Role MUC');
        insert role;

        Test.startTest();
        List<MassUserCreatorController.OptionWrapper> result =
            MassUserCreatorController.getUserRoles();
        Test.stopTest();

        System.assertNotEquals(0, result.size(),
            'Debe haber al menos un rol.');
    }

    @IsTest
    static void testGetPermissionSets() {
        Test.startTest();
        List<MassUserCreatorController.OptionWrapper> result =
            MassUserCreatorController.getPermissionSets();
        Test.stopTest();

        // Puede ser vacío en una scratch org limpia; solo validamos que no lance
        System.assertNotEquals(null, result, 'El resultado no debe ser nulo.');
    }

    // ── Tests de creación ─────────────────────────────────────────────────────

    @IsTest
    static void testCreateUsersSingleSuccess() {
        Id profileId = getTestProfileId();

        MassUserCreatorController.UserInputWrapper input =
            new MassUserCreatorController.UserInputWrapper();
        input.firstName        = 'Juan';
        input.lastName         = 'Pérez';
        input.email            = 'juan.perez.test@example.com';
        input.username         = 'juan.perez.test@example.muc';
        input.profileId        = profileId;
        input.roleId           = null;
        input.permissionSetIds = new List<String>();

        Test.startTest();
        List<MassUserCreatorController.UserResultWrapper> results =
            MassUserCreatorController.createUsers(
                new List<MassUserCreatorController.UserInputWrapper>{ input }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success,
            'El usuario debió crearse correctamente. Error: ' +
            results[0].errorMessage);
        System.assertNotEquals(null, results[0].userId);
    }

    @IsTest
    static void testCreateUsersBulk() {
        Id profileId = getTestProfileId();
        List<MassUserCreatorController.UserInputWrapper> inputs =
            new List<MassUserCreatorController.UserInputWrapper>();

        for (Integer i = 0; i < 5; i++) {
            MassUserCreatorController.UserInputWrapper inp =
                new MassUserCreatorController.UserInputWrapper();
            inp.firstName        = 'User';
            inp.lastName         = 'Bulk' + i;
            inp.email            = 'bulk.user.' + i + '@example.com';
            inp.username         = 'bulk.user.' + i + '@example.muc';
            inp.profileId        = profileId;
            inp.roleId           = null;
            inp.permissionSetIds = new List<String>();
            inputs.add(inp);
        }

        Test.startTest();
        List<MassUserCreatorController.UserResultWrapper> results =
            MassUserCreatorController.createUsers(inputs);
        Test.stopTest();

        System.assertEquals(5, results.size(), 'Deben retornarse 5 resultados.');
        for (MassUserCreatorController.UserResultWrapper r : results) {
            System.assertEquals(true, r.success,
                'Fallo al crear usuario: ' + r.errorMessage);
        }
    }

    @IsTest
    static void testCreateUserWithPermissionSet() {
        Id profileId = getTestProfileId();

        // Crear un Permission Set de prueba
        PermissionSet ps = new PermissionSet(
            Name  = 'TestPS_MUC',
            Label = 'Test PS MUC'
        );
        insert ps;

        MassUserCreatorController.UserInputWrapper input =
            new MassUserCreatorController.UserInputWrapper();
        input.firstName        = 'Maria';
        input.lastName         = 'Garcia';
        input.email            = 'maria.garcia.test@example.com';
        input.username         = 'maria.garcia.test@example.muc';
        input.profileId        = profileId;
        input.roleId           = null;
        input.permissionSetIds = new List<String>{ ps.Id };

        Test.startTest();
        List<MassUserCreatorController.UserResultWrapper> results =
            MassUserCreatorController.createUsers(
                new List<MassUserCreatorController.UserInputWrapper>{ input }
            );
        Test.stopTest();

        System.assertEquals(true, results[0].success,
            'El usuario con PS debió crearse. Error: ' + results[0].errorMessage);

        // Verificar que se asignó el PS
        List<PermissionSetAssignment> assignments = [
            SELECT Id FROM PermissionSetAssignment
            WHERE  AssigneeId = :results[0].userId
            AND    PermissionSetId = :ps.Id
        ];
        System.assertEquals(1, assignments.size(),
            'Debe existir la asignación del Permission Set.');
    }

    @IsTest
    static void testCreateUsersInvalidProfile() {
        MassUserCreatorController.UserInputWrapper input =
            new MassUserCreatorController.UserInputWrapper();
        input.firstName        = 'Error';
        input.lastName         = 'User';
        input.email            = 'error.user@example.com';
        input.username         = 'error.user@example.muc';
        input.profileId        = '000000000000000'; // ID inválido
        input.roleId           = null;
        input.permissionSetIds = new List<String>();

        Test.startTest();
        List<MassUserCreatorController.UserResultWrapper> results =
            MassUserCreatorController.createUsers(
                new List<MassUserCreatorController.UserInputWrapper>{ input }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success,
            'Un perfil inválido debe retornar success = false.');
        System.assertNotEquals(null, results[0].errorMessage,
            'Debe existir un mensaje de error.');
    }

    @IsTest
    static void testCreateUsersEmptyList() {
        Test.startTest();
        List<MassUserCreatorController.UserResultWrapper> results =
            MassUserCreatorController.createUsers(
                new List<MassUserCreatorController.UserInputWrapper>()
            );
        Test.stopTest();

        System.assertEquals(0, results.size(),
            'Lista vacía debe retornar 0 resultados.');
    }

    @IsTest
    static void testCreateUsersNullInput() {
        Test.startTest();
        List<MassUserCreatorController.UserResultWrapper> results =
            MassUserCreatorController.createUsers(null);
        Test.stopTest();

        System.assertEquals(0, results.size(),
            'Input nulo debe retornar lista vacía.');
    }
}