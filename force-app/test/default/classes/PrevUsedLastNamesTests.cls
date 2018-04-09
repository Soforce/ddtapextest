@isTest
private class PrevUsedLastNamesTests {
    @isTest
    static void testLastNameNotChange() {
        (new LastNameNotChangeTester()).runTest();
    }

    @isTest
    static void testNewLastNameForEmptyPrevNames() {
        (new NewLastNameForEmptyPrevNamesTester()).runTest();
    }

    @isTest
    static void testNewLastNameForNotEmptyPrevNames() {
        (new NewLastNameForNotEmptyPrevNamesTester()).runTest();
    }

    @isTest
    static void testExistingLastName() {
        (new ExistingLastNameTester()).runTest();
    }

    @isTest
    static void testExceedingFieldLenOfPrevNames() {
        (new ExceedingFieldLenOfPrevNamesTester()).runTest();
    }  

    /*
     * @description Base test class for the test scenario
     */
    virtual class BaseTester {
        Map<String, Object> ctx;

        BaseTester() {
            ctx = new Map<String, Object>();
        }
        /*
         * @description Entry point to execute the individual test case
         */
        public void runTest() { 
            // System.runAs(user) {
            initialize(ctx);
            prepare(ctx);
            setupTestData(ctx);
            executeProcess(ctx);
            readResultData(ctx);
            validate(ctx);
            // }
        } 

        protected virtual void initialize(Map<String, Object> ctx) {}
        protected virtual void prepare(Map<String, Object> ctx) {
            Contact c = new Contact(
                FirstName = 'John',
                LastName = 'Smith'
            );
            insert c;

            ctx.put('contact', c);
        }

        protected virtual void setupTestData(Map<String, Object> ctx) {}
        protected virtual void executeProcess(Map<String, Object> ctx) {
            Contact prevC = (Contact)ctx.get('contact');
            String newLastName = (String)ctx.get('newLastName');

            Contact newC = new Contact(
                Id = prevC.Id,
                LastName = newLastName
            );
            update newC;
        }

        protected virtual void readResultData(Map<String, Object> ctx) {
            Contact c = (Contact)ctx.get('contact');
            Contact updatedContact = [SELECT FirstName, LastName, Prev_Lastnames__c FROM Contact WHERE Id=:c.Id];
            ctx.put('updatedContact', updatedContact);
        }
        protected virtual void validate(Map<String, Object> ctx) {}
    }

    class LastNameNotChangeTester extends BaseTester { 
        protected override void setupTestData(Map<String, Object> ctx) {
            String newLastName = 'Smith'; // Lastname is not changed
            ctx.put('newLastName', newLastName);
        }

        protected override void validate(Map<String, Object> ctx) {
            Contact updatedContact = (Contact)ctx.get('updatedContact');
            System.assertEquals(null, updatedContact.Prev_Lastnames__c);
        }
    }

    class NewLastNameForEmptyPrevNamesTester extends BaseTester { 
        protected override void setupTestData(Map<String, Object> ctx) {
            String newLastName = 'Rees';
            ctx.put('newLastName', newLastName);
        }

        protected override void validate(Map<String, Object> ctx) {
            Contact updatedContact = (Contact)ctx.get('updatedContact');
            System.assertEquals('Smith', updatedContact.Prev_Lastnames__c);
        }
    }
    class NewLastNameForNotEmptyPrevNamesTester extends BaseTester { 
        protected override void prepare(Map<String, Object> ctx) {
            super.prepare(ctx);
            Contact c = (Contact)ctx.get('contact');
            c.Prev_Lastnames__c = 'Sampson'; // Previous last name is not empty
            update c;
        }

        protected override void setupTestData(Map<String, Object> ctx) {
            String newLastName = 'Rees';
            ctx.put('newLastName', newLastName);
        }

        protected override void validate(Map<String, Object> ctx) {
            Contact updatedContact = (Contact)ctx.get('updatedContact');
            System.assertEquals('Smith, Sampson', updatedContact.Prev_Lastnames__c);
        }
    }

    class ExistingLastNameTester extends BaseTester {
        protected override void prepare(Map<String, Object> ctx) {
            super.prepare(ctx);
            Contact c = (Contact)ctx.get('contact');
            c.Prev_Lastnames__c = 'Sampson, Smith'; // Previous last name is not empty
            update c;
        }

        protected override void setupTestData(Map<String, Object> ctx) {
            String newLastName = 'Rees';
            ctx.put('newLastName', newLastName);
        }

        protected override void validate(Map<String, Object> ctx) {
            Contact updatedContact = (Contact)ctx.get('updatedContact');
            System.assertEquals('Sampson, Smith', updatedContact.Prev_Lastnames__c);
        }
    }
    class ExceedingFieldLenOfPrevNamesTester extends BaseTester { 
        protected override void prepare(Map<String, Object> ctx) {
            super.prepare(ctx);
            Contact c = (Contact)ctx.get('contact');
            c.Prev_Lastnames__c = 'Sarndal, Biever, LastXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXName';
            update c;
        }

        protected override void setupTestData(Map<String, Object> ctx) {
            String newLastName = 'Rees';
            ctx.put('newLastName', newLastName);
        }

        protected override void validate(Map<String, Object> ctx) {
            Contact updatedContact = (Contact)ctx.get('updatedContact');
            System.assertEquals('Smith, Sarndal, Biever', updatedContact.Prev_Lastnames__c);
        }
    }
}
