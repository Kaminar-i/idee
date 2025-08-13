use starknet::ContractAddress;
use crate::types::RegistryTypes;

#[starknet::interface]
pub trait IIssuerRegistry<TContractState> {
    fn issue_credential(
        ref self: TContractState, holder_id: felt252, credential_hash: felt252,
    ) -> bool;

    fn revoke_credntial(
        ref self: TContractState, holder_id: felt252, credential_hash: felt252, reason: felt252,
    ) -> bool;

    fn register_issuer(
        ref self: TContractState, issuer_addres: ContractAddress, metadata: felt252,
    ) -> bool;

    fn verify_proof_commitment(
        self: @TContractState,
        proof_commitment: felt252,
        disclosed_claims_hash: felt252,
        verifier_requirements: Array<felt252>,
    ) -> bool;

    fn verify_credential_status(
        self: @TContractState, credential_hash: felt252,
    ) -> RegistryTypes::CredentialStatus;
}
