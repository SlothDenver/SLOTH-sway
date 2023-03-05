use fuels::prelude::*;
use fuels::tx::Address;
use crate::contract::setup;

mod success {
    use super::*;

    #[tokio::test]
    async fn should_check_balance_for_an_account() {
        let (instance, _id) = setup::get_contract_instance().await;
        let account = Identity::Address(Address::from(instance.get_wallet().address()));

        let result = instance.methods().balance_of(account).call().await;
        assert_eq!(result.is_ok(), true);
        assert_eq!(result.unwrap().value, 0);
    }
}
