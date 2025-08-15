use starknet::ContractAddress;
#[starknet::interface]
pub trait IIssuerRegistry<TContractState> {
    fn issue_credential(
        ref self: TContractState,
        admin_registry_address: ContractAddress,
        holder_address: ContractAddress,
        holder_id: felt252,
        credential_hash: felt252,
    );

    fn revoke_credntial(
        ref self: TContractState,
        admin_registry_address: ContractAddress,
        holder_address: ContractAddress,
        holder_id: felt252,
        credential_hash: felt252,
        reason: felt252,
    );

    fn anchor_vc_root(ref self: TContractState, vc_root: felt252);
    fn is_vc_root_anchored(self: @TContractState, vc_root: felt252) -> bool;

    fn set_status_root(
        ref self: TContractState, schema: felt252, list_id: felt252, new_root: felt252,
    );
    fn get_status_root(
        self: @TContractState, issuer: ContractAddress, schema: felt252, list_id: felt252,
    ) -> felt252;
}
