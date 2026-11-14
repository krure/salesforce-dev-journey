// Datos semilla para scratch orgs: roles de ejemplo para poblar el combobox del LWC.
// Es idempotente: se puede ejecutar varias veces.
List<String> roleNames = new List<String>{ 'Sales Manager', 'Support Engineer', 'Developer' };

Set<String> existing = new Set<String>();
for (UserRole r : [SELECT Name FROM UserRole WHERE Name IN :roleNames]) {
    existing.add(r.Name);
}

List<UserRole> toInsert = new List<UserRole>();
for (String name : roleNames) {
    if (!existing.contains(name)) {
        toInsert.add(new UserRole(Name = name, DeveloperName = name.replace(' ', '_')));
    }
}

if (!toInsert.isEmpty()) {
    insert toInsert;
}
System.debug('Roles creados: ' + toInsert.size());
