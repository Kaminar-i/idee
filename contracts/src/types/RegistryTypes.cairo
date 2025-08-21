use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
pub struct CredentialIssued {
    #[key]
    pub holder: felt252,
    #[key]
    pub issuer: ContractAddress,
}

#[derive(Drop, starknet::Event)]
pub struct CredentialRevoked {
    #[key]
    pub issuer: ContractAddress,
    pub reason: felt252,
}

#[derive(Drop, starknet::Event)]
pub struct IssuerRegistered {
    #[key]
    pub issuer: ContractAddress,
    pub metadata: felt252,
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

#[derive(Default, Drop, Copy, Serde, PartialEq, starknet::Store)]
pub struct Credential {
    pub status: CredentialStatus,
    pub holder_id: felt252,
    pub credential_hash: felt252,
}
