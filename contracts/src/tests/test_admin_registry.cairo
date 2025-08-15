use idee::interfaces::IAdminRegistry::IAdminRegistryDispatcher;
use snforge_std::{declare, test_address};
use starknet::ContractAddress;

fn deploy() -> IAdminRegistryDispatcher {
    let contract = declare("IssuerRegistry").unwrap().contract_class();
    let mut constructor_calldata = array![];
    let owner: ContractAddress = OWNER().try_into().unwrap();
    owner.serialize(ref constructor_calldata);
    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    IAdminRegistryDispatcher { contract_address }
}

#[test]
fn test_issuer_lifecycle() {
    // Setup
    let admin = test_address();
    let issuer = test_address();

    // Test registration
    start_prank(admin);
    dispatcher.register_issuer(issuer, 'TestIssuer');

    // Verify registration
    let info = dispatcher.get_issuer_info(issuer);
    assert(info.name == 'TestIssuer', 'Name mismatch');
    assert(dispatcher.is_issuer_active(issuer), 'Should be active');

    // Test revocation
    dispatcher.revoke_issuer(issuer, 'NonCompliance');
    assert(!dispatcher.is_issuer_active(issuer), 'Should be inactive');

    // Test enumeration
    let all_issuers = dispatcher.get_all_issuers();
    assert(all_issuers.len() == 1, 'Should have 1 issuer');
    assert(all_issuers.at(0) == issuer, 'Wrong issuer address');
}

#[test]
#[should_panic]
fn test_unauthorized_registration() {
    let admin = test_address(1);
    let attacker = test_address(999);
    let issuer = test_address(2);

    let contract = declare("IssuerRegistry");
    let contract_address = contract.deploy(@array![admin.into()]).unwrap();
    let dispatcher = IAdminRegistryDispatcher { contract_address };

    start_prank(attacker);
    dispatcher.register_issuer(issuer, 'MaliciousIssuer'); // Should panic
}
