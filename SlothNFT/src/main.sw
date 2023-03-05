contract;

dep errors;
dep interface;

use errors::{AccessError, InitError, InputError};
use interface::{MintEvent, NFT, TransferEvent};
use std::{
    auth::msg_sender,
    auth::AuthError,
    identity::Identity,
    logging::log,
    option::Option,
    result::Result,
    revert::require,
    storage::StorageMap,
};
use std::{
    call_frames::{
        contract_id,
        msg_asset_id,
    },
    context::msg_amount,
    token::{
        mint_to_address,
        transfer_to_address,
    },
};

const BASE_TOKEN = ContractId::from(0xe68c8aa10ad7fa41743033b6775890574016d0368cacd477040fa8f52c0fbeea);
const RECEIVER_ADDRESS: b256 = 0xddec0e7e6a9a4a4e3e57d08d080d71a299c628a46bc609aab4627695679421ca; // 내 addr로 바꿔야함

storage {
    access_control: bool = false,
    admin: Option<Identity> = Option::None,
    // receiver: Identity = Identity::Address(Address::from(RECEIVER_ADDRESS)),
    receiver: Address = Address::from(RECEIVER_ADDRESS),
    balances: StorageMap<Address, u64> = StorageMap {},
    max_supply: u64 = 1000, // 현재는
    owners: StorageMap<u64, Option<Address>> = StorageMap {},
    price_info: StorageMap<(u64), u64> = StorageMap {},
    total_supply: u64 = 0,
    base_uri: str[128] = "                                                                                                                                ",

}
fn get_msg_sender_address_or_panic() -> Address {
    let sender: Result<Identity, AuthError> = msg_sender();
    if let Identity::Address(address) = sender.unwrap() {
        address
    } else {
        revert(0);
    }
}

fn get_address_or_panic(ident: Identity) -> Address {
    // let sender: Result<Identity, AuthError> = ident;
    if let Identity::Address(address) = ident {
        address
    } else {
        revert(0);
    }
}

impl NFT for Contract {
    #[storage(read)]
    fn admin() -> Identity {
        let admin = storage.admin;
        require(admin.is_some(), InputError::AdminDoesNotExist);
        admin.unwrap()
    }

    #[storage(read)]
    fn balance_of(owner: Identity) -> u64 {
        let addr = get_address_or_panic(owner);
        storage.balances.get(addr)
    }

    #[storage(read)]
    fn get_token_owner(token_id: u64) -> Address {
        storage.owners.get(token_id).unwrap()
    }

    #[storage(read, write)]
    fn constructor() {
        let admin = Option::Some(msg_sender().unwrap());
        require(storage.max_supply == 0, InitError::CannotReinitialize);
        storage.access_control = true;
        storage.admin = admin;
        storage.max_supply = 1000;
    }

    #[storage(read)]
    fn max_supply() -> u64 {
        storage.max_supply
    }

    #[storage(read, write), payable]
    fn mint(amount: u64) {
        let sender_addr = get_msg_sender_address_or_panic();
        let total_supply = storage.total_supply;
        let token_id = total_supply + 1;
        require(storage.max_supply >= token_id, InputError::NotEnoughTokensToMint);
        require(msg_asset_id() == BASE_TOKEN, "wrong base token");
        require(msg_amount() == 1_000_000_000_000, "wrong amount of token");

        // let admin = storage.admin;
        // require(!storage.access_control || (admin.is_some() && msg_sender().unwrap() == admin.unwrap()), AccessError::SenderNotAdmin);

        storage.owners.insert(token_id, Option::Some(sender_addr));
        storage.balances.insert(sender_addr, storage.balances.get(sender_addr) + 1);
        storage.price_info.insert(token_id, 1_000_000_000_000);
        storage.total_supply += 1;
        log(MintEvent {
            owner: sender_addr,
            token_id,
        });
    }

    #[storage(read)]
    fn total_supply() -> u64 {
        storage.total_supply
    }

    #[storage(read, write)]
    fn transfer_from(from: Address, to: Address, token_id: u64) {
        let token_owner = storage.owners.get(token_id);
        require(token_owner.is_some(), InputError::TokenDoesNotExist);
        let token_owner = token_owner.unwrap();

        storage.owners.insert(token_id, Option::Some(to));
        storage.balances.insert(from, storage.balances.get(from) - 1);
        storage.balances.insert(to, storage.balances.get(to) + 1);

        log(TransferEvent {
            from,
            to,
            token_id,
        });
    }

    #[storage(read, write), payable]
    fn redeem(token_id: u64, recipient: Address) {
        let owner = get_msg_sender_address_or_panic();
        let token_owner = storage.owners.get(token_id);
        // require(token_owner.is_some(), InputError::TokenDoesNotExist);
        require(owner == token_owner.unwrap(), "Wrong Owner");

        let redeemAmount = storage.price_info.get((token_id));
        transfer_to_address(redeemAmount, BASE_TOKEN, recipient);
        storage.price_info.insert((token_id), 0);
        storage.owners.insert(token_id, Option::Some(storage.receiver));
        storage.balances.insert(owner, storage.balances.get(owner) - 1);
        storage.balances.insert(storage.receiver, storage.balances.get(storage.receiver) + 1);
    }

}