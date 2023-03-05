use fuels::{prelude::*, tx::ContractId};

pub mod setup {
    use super::*;

    // Load abi from json
    abigen!(MyContract, "out/debug/nft-abi.json");

    pub async fn get_contract_instance() -> (MyContract, ContractId) {
        // Launch a local network and deploy the contract
        let mut wallets = launch_custom_provider_and_get_wallets(
            WalletsConfig::new(
                Some(1),             /* Single wallet */
                Some(1),             /* Single coin (UTXO) */
                Some(1_000_000_000), /* Amount per coin */
            ),
            None,
            None,
        )
        .await;
        let wallet = wallets.pop().unwrap();
    
        let id = Contract::deploy(
            "./out/debug/nft.bin",
            &wallet,
            TxParameters::default(),
            StorageConfiguration::with_storage_path(Some(
                "./out/debug/nft-storage_slots.json".to_string(),
            )),
        )
        .await
        .unwrap();
    
        let instance = MyContract::new(id.clone(), wallet);
    
        (instance, id.into())
    }
}
