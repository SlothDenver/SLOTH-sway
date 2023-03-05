library interface;

use std::{identity::Identity, option::Option};

pub struct TransferEvent {
    from: Address,
    to: Address,
    token_id: u64,
}

pub struct MintEvent {
    owner: Address,
    token_id: u64,
}

abi NFT {
    #[storage(read)]
    fn admin() -> Identity;

    #[storage(read)]
    fn balance_of(owner: Identity) -> u64;

    #[storage(read)]
    fn get_token_owner(token_id: u64) -> Address;

    #[storage(read, write)]
    fn constructor();

    #[storage(read)]
    fn max_supply() -> u64;

    #[storage(read, write), payable]
    fn mint(amount: u64);

    #[storage(read)]
    fn total_supply() -> u64;

    #[storage(read, write)]
    fn transfer_from(from: Address, to: Address, token_id: u64);

    #[storage(read, write), payable]
    fn redeem(token_id: u64, recipient: Address);

}