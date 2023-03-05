use crate::contract::setup;

mod success {
    use super::*;

    #[tokio::test]
    async fn should_return_max_supply() {
        let (instance, _id) = setup::get_contract_instance().await;
        let result = instance.methods().max_supply().call().await;

        assert_eq!(result.is_ok(), true);
        assert_eq!(result.unwrap().value, 10000);
    }
}