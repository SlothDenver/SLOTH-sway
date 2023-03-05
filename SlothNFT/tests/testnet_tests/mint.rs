use dotenv::dotenv;
use fuels::prelude::*;
use std::str::FromStr;
use fuels::tx::AssetId;

const ADDRESS: &str = "0x74127076a5b0fe6c9ca7e1656656f31e364b86ce69a95d6896a20cdff34d5348"; // CONTRACT ADDRESS
const ADMIN_ADDRESS: &str = "fuel17dlzg2a4xpuf54c5cqwze5nxafweclzasqk95exqpemmvrnemn9q3vh4sf";
const USDC: &str = "0xfe82260d196cdf11c7983d7019db0838b9971388c6954cb6db5daa23f51fe823";

abigen!(NFTContract, "out/debug/nft-abi.json");

const RPC: &str = "node-beta-2.fuel.network";

#[tokio::test]
async fn mintTest() {
    let provider = match Provider::connect(RPC).await {
        Ok(p) => p,
        Err(error) => panic!("❌ Problem creating provider: {:#?}", error),
    };

    dotenv().ok();
    let secret = match std::env::var("SECRET") {
        Ok(s) => s,
        Err(error) => panic!("❌ Cannot find .env file: {:#?}", error),
    };

    let wallet =
        WalletUnlocked::new_from_private_key(secret.parse().unwrap(), Some(provider.clone()));

    let token_id = Bech32ContractId::from(ContractId::from_str(ADDRESS).unwrap());
    let instance = NFTContract::new(token_id, wallet.clone());

    println!("👛 Account address     @ {}", wallet.clone().address());
    println!(
        "🗞  Token address   @ {}",
        instance.get_contract_id()
    );

    let wallet_address: Address = wallet.clone().address().into();

    let wallet_identity = Identity::Address(wallet_address);
    
//     // turn an unlocked wallet into an Identity
//     let wallet_identity_copy = Identity::Address(wallet.address().into());

    // Bytes representation of the asset ID of the base asset used for gas fees.
    // let BASE_ASSET_ID = AssetId::from_str(ADDRESS).unwrap();
    let asset_id = AssetId::from_str(ADDRESS).unwrap();
    let usdc_id = AssetId::from_str(USDC).unwrap();

    // call params to send the base asset
    // let call_params = CallParameters::new(Some(1_000_000_000_000), Some(usdc_id), None);

    // let result = instance
    //     .methods()
    //     .mint(wallet_identity, 100)
    //     .append_variable_outputs(1)
    //     .call_params(call_params)
    //     .call()
    //     .await;
    let result = instance
            .methods()
            .mint(wallet_address, 10000)
            .call().
            await;

    println!("{} mintTest", if result.is_ok() { "✅" } else { "❌" });

    let balance = wallet.get_asset_balance(&usdc_id).await.unwrap();
    println!(
        "Wallet balance: {}",
        {balance}
    );
    // let balance_1 = instance.methods().total_supply().call().await;
    // println!("{}",balance_1);
    // println!(
    //     "totalSupply: {}",
    //     {balance_1}
    // );


}