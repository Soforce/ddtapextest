@isTest
private class PrevUsedLastNamesTests {
    @isTest
    static void testLastNameNotChange() {
        (new LastNameNotChangeTest()).runTest();
    }

    @isTest
    static void testNewLastNameForEmptyPrevNames() {
        (new NewLastNameForEmptyPrevNamesTest()).runTest();
    }

    @isTest
    static void testNewLastNameForNotEmptyPrevNames() {
        (new NewLastNameForNotEmptyPrevNamesTest()).runTest();
    }

    @isTest
    static void testExistingLastName() {
        (new ExistingLastNameTest()).runTest();
    }

    @isTest
    static void testExceedingFieldLenOfPrevNames() {
        (new ExceedingFieldLenOfPrevNamesTest()).runTest();
    }  

    virtual class BaseTest {
        Contact originalContact;    // Contact before the update
        Contact contactToUpdate;    // Contact with reguired changes to be updated
        Contact updatedContact;     // Updated Contact retrieved from database

        /*
         * @description Entry point to execute the individual test case
         */
        public void runTest() { 
            originalContact = new Contact();
            contactToUpdate = new Contact();

            setupData();
            insert originalContact;

            updateContact();

            retrieveContact();

            validateContact();
        } 

        /*
         * @description Data prep to be implemented by child class
         */
        virtual void setupData() {} 
        /*
         * @description Trigger the business process by updating the contact
         */
        virtual void updateContact() {
            contactToUpdate.Id = originalContact.Id;
            update contactToUpdate;
        } 

        /*
         * @descrption Retrive the updated Contact for validation
         */
        virtual void retrieveContact() {
            updatedContact = [SELECT FirstName, LastName, Prev_Lastnames__c FROM Contact WHERE Id=:originalContact.Id];
        } 

        /*
         * @description Validations to be implemented by child class
         */
        virtual void validateContact() {} 
    }

    class LastNameNotChangeTest extends BaseTest { 
        override void setupData() {
            originalContact.FirstName = 'John';
            originalContact.LastName = 'Smith';

            contactToUpdate.FirstName = 'Junior John';
            contactToUpdate.LastName = 'Smith'; // 
        }

        override void validateContact() {
            System.assertEquals(null, updatedContact.Prev_Lastnames__c);
        }
    }

    class NewLastNameForEmptyPrevNamesTest extends BaseTest { 
        override void setupData() {
            originalContact.FirstName = 'John';
            originalContact.LastName = 'Smith';

            contactToUpdate.FirstName = 'John';
            contactToUpdate.LastName = 'Rees'; // 
        }

        override void validateContact() {
            System.assertEquals('Smith', updatedContact.Prev_Lastnames__c);
        }
    }
    class NewLastNameForNotEmptyPrevNamesTest extends BaseTest { 
        override void setupData() {
            originalContact.FirstName = 'John';
            originalContact.LastName = 'Smith';
            originalContact.Prev_Lastnames__c = 'Sampson';

            contactToUpdate.FirstName = 'John';
            contactToUpdate.LastName = 'Rees'; // 
        }

        override void validateContact() {
            System.assertEquals('Smith, Sampson', updatedContact.Prev_Lastnames__c);
        }
    }
    class ExistingLastNameTest extends BaseTest {
        override void setupData() {
            originalContact.FirstName = 'John';
            originalContact.LastName = 'Smith';
            originalContact.Prev_Lastnames__c = 'Sampson, Smith';

            contactToUpdate.FirstName = 'John';
            contactToUpdate.LastName = 'Rees'; // 
        }

        override void validateContact() {
            System.assertEquals('Sampson, Smith', updatedContact.Prev_Lastnames__c);
        }
    }
    class ExceedingFieldLenOfPrevNamesTest extends BaseTest { 
        override void setupData() {
            originalContact.FirstName = 'John';
            originalContact.LastName = 'Smith';
            originalContact.Prev_LastNames__c = 'Sarndal, Biever, LastXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXName';

            contactToUpdate.FirstName = 'John';
            contactToUpdate.LastName = 'Rees'; // 
        }

        override void validateContact() {
            System.assertEquals('Smith, Sarndal, Biever', updatedContact.Prev_Lastnames__c);
        }
    }
}
