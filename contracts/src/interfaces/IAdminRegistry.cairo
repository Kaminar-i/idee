use idee::types::IssuerTypes::Issuer;
use starknet::ContractAddress;

#[starknet::interface]
pub trait IAdminRegistry<TContractState> {
    fn register_issuer(ref self: TContractState, issuer_address: ContractAddress, name: felt252);
    fn revoke_issuer(ref self: TContractState, issuer_address: ContractAddress, reason: felt252);
    fn get_issuer_info(self: @TContractState, issuer_address: ContractAddress) -> Issuer;
    fn is_issuer_active(self: @TContractState, issuer_address: ContractAddress) -> bool;
    fn get_all_issuers(self: @TContractState) -> Array<ContractAddress>;
}
