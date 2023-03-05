use crate::contract::setup;

mod success {
    use super::*;

    #[tokio::test]
    async fn should_initialize_contract_name_symbol() {
        let (instance, _id) = setup::get_contract_instance().await;
        let result = instance.methods().constructor().call().await;
        assert_eq!(result.is_ok(), true);
    }
}
