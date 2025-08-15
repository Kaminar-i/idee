use starknet::ContractAddress;

#[derive(Drop, Serde, starknet::Store)]
pub struct Issuer {
    pub name: felt252,
    pub is_active: bool,
    pub registration_date: u64 //TODO some of this things can be stored off chain
}

#[derive(Drop, Serde, starknet::Event)]
pub struct IssuerRegistered {
    #[key]
    pub issuer_address: ContractAddress,
    pub name: felt252,
}

#[derive(Drop, Serde, starknet::Event)]
pub struct IssuerDeactivated {
    #[key]
    pub issuer_address: ContractAddress,
    pub reason: felt252,
}
