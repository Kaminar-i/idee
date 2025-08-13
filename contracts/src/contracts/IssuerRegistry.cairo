#[starknet::contract]
pub mod IssuerRegistry {
    use bool::True;
    use idee::interfaces::IIssuerRegistry::IIssuerRegistry;
    use idee::types::RegistryTypes::{
        CredentialIssued, CredentialRevoked, CredentialStatus, IssuerRegistered,
    };
    use starknet::ContractAddress;

    #[storage]
    pub struct Storage {}

    #[event]
    #[derive(starknet::Event)]
    enum Event {
        CredentialIssued: CredentialIssued,
        CredentialRevoked: CredentialRevoked,
        IssuerRegistered: IssuerRegistered,
    }

    impl IssuerRegistryImpl of IIssuerRegistry<ContractState> {
        fn issue_credential(
            ref self: ContractState, holder_id: felt252, credential_hash: felt252,
        ) -> bool {
            True
        }

        fn revoke_credntial(
            ref self: ContractState, holder_id: felt252, credential_hash: felt252, reason: felt252,
        ) -> bool {
            True
        }

        fn register_issuer(
            ref self: ContractState, issuer_addres: ContractAddress, metadata: felt252,
        ) -> bool {
            True
        }

        fn verify_proof_commitment(
            self: @ContractState,
            proof_commitment: felt252,
            disclosed_claims_hash: felt252,
            verifier_requirements: Array<felt252>,
        ) -> bool {
            True
        }

        fn verify_credential_status(
            self: @ContractState, credential_hash: felt252,
        ) -> CredentialStatus {
            CredentialStatus::Active
        }
    }
}
