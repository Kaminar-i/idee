use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
struct CredentialIssued {
    #[key]
    holder: felt252,
    #[key]
    issuer: ContractAddress,
    credential_hash: felt252,
    schema_version: u32,
}

#[derive(Drop, starknet::Event)]
struct CredentialRevoked {
    #[key]
    credential_hash: felt252,
    reason: felt252,
}

#[derive(Drop, starknet::Event)]
struct IssuerRegistered {
    #[key]
    issuer: ContractAddress,
    metadata: felt252,
}

#[derive(Default, Drop, Copy, Serde, PartialEq, starknet::Store)]
pub enum CredentialStatus {
    #[default]
    Active,
    Revoked,
}

impl CredentialIntoFelt252 of Into<CredentialStatus, felt252> {
    fn into(self: CredentialStatus) -> felt252 {
        match self {
            CredentialStatus::Active => 'Active',
            CredentialStatus::Revoked => 'Revoked',
        }
    }
}

impl Felt252TryIntoGenre of TryInto<felt252, CredentialStatus> {
    fn try_into(self: felt252) -> Option<CredentialStatus> {
        if self == 'Active' {
            Option::Some(CredentialStatus::Active)
        } else if self == 'Revoked' {
            Option::Some(CredentialStatus::Revoked)
        } else {
            Option::None
        }
    }
}
