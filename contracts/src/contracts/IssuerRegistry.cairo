#[starknet::contract]
pub mod IssuerRegistry {
    use idee::interfaces::IAdminRegistry::IAdminRegistryDispatcher;
    use idee::interfaces::IIssuerRegistry::IIssuerRegistry;
    use idee::types::RegistryTypes::{
        Credential, CredentialIssued, CredentialRevoked, CredentialStatus,
    };
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePathEntry};
    use starknet::{ContractAddress, get_caller_address};
    use crate::interfaces::IAdminRegistry::IAdminRegistryDispatcherTrait;

    #[storage]
    struct Storage {
        admin_registry: ContractAddress,
        credentials: Map<ContractAddress, Map<ContractAddress, Credential>>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CredentialIssued: CredentialIssued,
        CredentialRevoked: CredentialRevoked,
    }

    impl IssuerRegistryImpl of IIssuerRegistry<ContractState> {
        fn issue_credential(
            ref self: ContractState,
            admin_registry_address: ContractAddress,
            holder_address: ContractAddress,
            holder_id: felt252,
            credential_hash: felt252,
        ) {
            let admin_contract = IAdminRegistryDispatcher {
                contract_address: admin_registry_address,
            };
            let caller = get_caller_address();
            let issuer = admin_contract.get_issuer_info(caller);
            assert(!issuer.is_active, 'Issuer is not active');
            let credential = Credential {
                holder_id: holder_id,
                credential_hash: credential_hash,
                status: CredentialStatus::Active,
            };
            self.credentials.entry(caller).write(holder_address, credential);
            self.emit(CredentialIssued { holder: holder_id, issuer: caller });
        }


        fn revoke_credntial(
            ref self: ContractState,
            admin_registry_address: ContractAddress,
            holder_address: ContractAddress,
            holder_id: felt252,
            credential_hash: felt252,
            reason: felt252,
        ) {
            let admin_contract = IAdminRegistryDispatcher {
                contract_address: admin_registry_address,
            };
            let caller = get_caller_address();
            let issuer = admin_contract.get_issuer_info(caller);
            assert(!issuer.is_active, 'Issuer is not active');
            let mut credential = self.credentials.entry(caller).read(holder_address);

            credential.status = CredentialStatus::Revoked;
            self.credentials.entry(caller).write(holder_address, credential);
            self.emit(CredentialRevoked { issuer: caller, reason: reason })
        }

        fn anchor_vc_root(ref self: ContractState, vc_root: felt252) {}

        fn is_vc_root_anchored(self: @ContractState, vc_root: felt252) -> bool {
            false
        }

        fn set_status_root(
            ref self: ContractState, schema: felt252, list_id: felt252, new_root: felt252,
        ) {}

        fn get_status_root(
            self: @ContractState, issuer: ContractAddress, schema: felt252, list_id: felt252,
        ) -> felt252 {
            0
        }
    }
}
