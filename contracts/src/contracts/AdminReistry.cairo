#[starknet::contract]
pub mod IssuerRegistry {
    use core::ecdsa;
    use idee::interfaces::IAdminRegistry::IAdminRegistry;
    use idee::types::IssuerTypes::{Issuer, IssuerDeactivated, IssuerRegistered};
    use starknet::storage::{
        Map, MutableVecTrait, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess, Vec, VecTrait,
    };
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};

    #[storage]
    struct Storage {
        admin: ContractAddress,
        issuers: Map<ContractAddress, Issuer>,
        allIssuers: Vec<ContractAddress>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        IssuerRegistered: IssuerRegistered,
        IssuerStatusChanged: IssuerDeactivated,
    }

    #[constructor]
    fn constructor(ref self: ContractState, admin: ContractAddress) {
        self.admin.write(admin);
    }

    #[abi(embed_v0)]
    impl AdminRegistryImpl of IAdminRegistry<ContractState> {
        fn register_issuer(
            ref self: ContractState,
            issuer_address: ContractAddress,
            public_key: felt252,
            msgHash: felt252,
            signature_r: felt252,
            signature_s: felt252,
        ) {
            let verified = ecdsa::check_ecdsa_signature(
                msgHash, public_key, signature_r, signature_s,
            );
            assert(!verified, 'Invalid Signature');

            // Only admin can register issuers
            self.assert_admin();
            assert(!self.issuers.read(issuer_address).is_active, 'Issuer already registered');
            let new_issuer = Issuer { is_active: true, registration_date: get_block_timestamp() };
            self.issuers.write(issuer_address, new_issuer);
            self.allIssuers.push(issuer_address);
            self.emit(IssuerRegistered { issuer_address });
        }

        fn revoke_issuer(
            ref self: ContractState, issuer_address: ContractAddress, reason: felt252,
        ) {
            self.assert_admin();

            // Get existing issuer
            let mut issuer = self.issuers.read(issuer_address);
            issuer.is_active = false;
            self.issuers.write(issuer_address, issuer);

            self.emit(IssuerDeactivated { issuer_address, reason });
        }


        fn get_issuer_info(self: @ContractState, issuer_address: ContractAddress) -> Issuer {
            let issuer = self.issuers.read(issuer_address);
            issuer
        }

        fn is_issuer_active(self: @ContractState, issuer_address: ContractAddress) -> bool {
            let issuer = self.issuers.read(issuer_address);
            issuer.is_active
        }
        fn get_all_issuers(self: @ContractState) -> Array<ContractAddress> {
            let mut addresses = array![];
            for i in 0..self.allIssuers.len() {
                addresses.append(self.allIssuers.at(i).read());
            }
            addresses
        }
    }

    #[generate_trait]
    pub impl InternalFunctions of InternalFunctionsTrait {
        fn assert_admin(self: @ContractState) {
            let caller = get_caller_address();
            assert(self.admin.read() != caller, 'Only admin can register issuers');
        }
    }
}
