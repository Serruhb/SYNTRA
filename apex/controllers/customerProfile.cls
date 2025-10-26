// NOTE: This version is sanitized for sharing externally.
// - PII and sensitive custom fields replaced with /*<REDACTED__c>*/

public with sharing class CustomerProfile {

    // --- PROPERTIES ---
    private final Id accountId;
    public String lightningBaseUrl { get; private set; }

    public Id primaryContactId { get; private set; }
    public List<Case> openCases { get; private set; }
    public List<Case> closedCases { get; private set; }

    private final Set<String> VALID_STATUSES = new Set<String>{
        'Suspended', 'Pending Activation', 'Activated'
    };

    public Map<String, List<SBQQ__Subscription__c>> validContractsMap { get; private set; }
    private Map<Id, Contract> contractStore { get; set; }

    // --- CONSTRUCTOR ---
    public CustomerProfile(ApexPages.StandardController stdController) {
        this.accountId = stdController.getId();

        if (System.Url.getOrgDomainUrl() != null) {
            lightningBaseUrl = System.Url.getOrgDomainUrl().toExternalForm();
        }

        validContractsMap = new Map<String, List<SBQQ__Subscription__c>>();
        contractStore = new Map<Id, Contract>();
        openCases = new List<Case>();
        closedCases = new List<Case>();

        loadPrimaryContact();
        loadCases();
        loadSubscriptions();
    }

    // --- HELPER METHODS ---

    private void loadPrimaryContact() {
        try {
            List<Contract> contracts = [
                SELECT
                    SBQQ__Quote__r.SBQQ__PrimaryContact__c
                FROM Contract
                WHERE AccountId = :this.accountId
                  AND Status = 'Activated'
                  AND SBQQ__Quote__r.SBQQ__PrimaryContact__c != NULL
                ORDER BY StartDate DESC
                LIMIT 1
            ];

            if (!contracts.isEmpty()) {
                this.primaryContactId = contracts[0].SBQQ__Quote__r.SBQQ__PrimaryContact__c;
            }

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.WARNING,
                'Could not load primary contact.'
            ));
        }
    }

    private void loadCases() {
        try {
            this.openCases = [
                SELECT Id, CaseNumber, Subject, Status, CreatedDate
                FROM Case
                WHERE AccountId = :this.accountId AND IsClosed = false
                ORDER BY CreatedDate DESC
                LIMIT 1000
            ];

            this.closedCases = [
                SELECT Id, CaseNumber, Subject, Status, ClosedDate
                FROM Case
                WHERE AccountId = :this.accountId AND IsClosed = true
                ORDER BY ClosedDate DESC
                LIMIT 20
            ];

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Error loading cases.'
            ));
        }
    }

    private void loadSubscriptions() {
        try {
            List<SBQQ__Subscription__c> allSubscriptions = [
                SELECT Id,
                       SBQQ__Contract__r.Id,
                       SBQQ__Contract__r.ContractNumber,
                       SBQQ__Contract__r.Status,
                       SBQQ__Contract__r.ContractTerm,
                       SBQQ__Contract__r.EndDate,
                       SBQQ__Contract__r./*<REDACTED__c>*/,
                       SBQQ__Contract__r.StartDate,
                       SBQQ__Contract__r.Pricing_Family__c,
                       // Product Fields
                       SBQQ__Product__r.Name,
                       SBQQ__Product__r.IsActive,
                       // Subscription Fields
                       /*<REDACTED__c>*/,                     
                       SBQQ__Product__r.Simplified_Product_Name__c,
                       /*<REDACTED__c>*/,                      
                       SBQQ__Quantity__c,
                       /*<REDACTED__c>*/                       
                FROM SBQQ__Subscription__c
                WHERE SBQQ__TerminatedDate__c = NULL
                  AND SBQQ__Account__c = :this.accountId
                ORDER BY SBQQ__Contract__r.ContractNumber, SBQQ__Product__r.Name
            ];

            sortSubscriptions(allSubscriptions);

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Error loading subscriptions.'
            ));
        }
    }

    /**
    * @description Sort subscriptions.
    */
    private void sortSubscriptions(List<SBQQ__Subscription__c> allSubscriptions) {
        for (SBQQ__Subscription__c sub : allSubscriptions) {
            if (sub.SBQQ__Contract__r != null && sub.SBQQ__Contract__r.Status != null) {
                if (VALID_STATUSES.contains(sub.SBQQ__Contract__r.Status)) {

                    Id contractId = sub.SBQQ__Contract__r.Id;
                    String contractIdString = String.valueOf(contractId);

                    if (!validContractsMap.containsKey(contractIdString)) {
                        validContractsMap.put(contractIdString, new List<SBQQ__Subscription__c>());
                    }
                    validContractsMap.get(contractIdString).add(sub);

                    if (!contractStore.containsKey(contractId)) {
                        contractStore.put(contractId, sub.SBQQ__Contract__r);
                    }
                }
            }
        }
    }

    public List<Contract> getValidContracts() {
        if (contractStore == null) {
            return new List<Contract>();
        }
        List<Contract> contracts = new List<Contract>(contractStore.values());
        contracts.sort();
        return contracts;
    }
}
