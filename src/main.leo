// The 'aleo_multisig' program.
import credits.aleo;

program aleo_multisig.aleo {
    const MAX_OWNERS:u8 = 14u8;
    const ZERO_ADDRESS:address = aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc;

    struct Wallet {
        wallet_address: address,
        owners: [address; 14],
        threshold: u8,
    }

    struct Transfer {
        wallet_address: address,
        to: address,
        amount: u64,
        confirmations: u8,
    }

    record Signer {
        owner: address,
        wallet_address: address,
        transfer_id: field,
    }

    mapping wallets: address => Wallet;
    mapping balances: address => u64;
    mapping transfers: field => Transfer;

    async transition create_wallet(wallet_address: address, owners: [address; 14],  threshold: u8) -> Future {
        assert_eq(threshold <= MAX_OWNERS && threshold >= 1u8, true);
        return finalize_create_wallet(wallet_address, owners, threshold);
    }

    async function finalize_create_wallet(wallet_address: address, owners: [address; 14],  threshold: u8) {
        assert_eq(Mapping::contains(wallets, wallet_address), false);
        let wallet: Wallet = Wallet {
            wallet_address: wallet_address,
            owners: owners,
            threshold: threshold,
        };
        Mapping::set(wallets, wallet_address, wallet);
        Mapping::set(balances, wallet_address, 0u64);
    }

    async transition deposit(wallet_address: address, amount: u64) -> Future {
        return finalize_deposit(wallet_address, amount, credits.aleo/transfer_public_as_signer(self.address, amount));
    }

    async function finalize_deposit(wallet_address: address, amount: u64, transfer: Future) {
        assert_eq(Mapping::contains(balances, wallet_address), true);
        let current_balance: u64 = Mapping::get(balances, wallet_address);
        let new_balance: u64 = current_balance + amount;
        Mapping::set(balances, wallet_address, new_balance);
        transfer.await();
    }

    async transition create_transfer(wallet: Wallet, to: address, amount: u64, transfer_id: field) -> (Signer, Signer, Signer, Signer, Signer, Signer, Signer, Signer, Signer, Signer, Signer, Signer, Signer, Signer, Future) {
        let signer1: Signer = Signer {
            owner: wallet.owners[0u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer2: Signer = Signer {
            owner: wallet.owners[1u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer3: Signer = Signer {
            owner: wallet.owners[2u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer4: Signer = Signer {
            owner: wallet.owners[3u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer5: Signer = Signer {
            owner: wallet.owners[4u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer6: Signer = Signer {
            owner: wallet.owners[5u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer7: Signer = Signer {
            owner: wallet.owners[6u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer8: Signer = Signer {
            owner: wallet.owners[7u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer9: Signer = Signer {
            owner: wallet.owners[8u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer10: Signer = Signer {
            owner: wallet.owners[9u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer11: Signer = Signer {
            owner: wallet.owners[10u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer12: Signer = Signer {
            owner: wallet.owners[11u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer13: Signer = Signer {
            owner: wallet.owners[12u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        let signer14: Signer = Signer {
            owner: wallet.owners[13u8],
            wallet_address: wallet.wallet_address,
            transfer_id: transfer_id,
        };

        return (signer1, signer2, signer3, signer4, signer5, signer6, signer7, signer8, signer9, signer10, signer11, signer12, signer13, signer14, finalize_create_transfer(wallet, to, amount, transfer_id, self.signer));
    }

    async function finalize_create_transfer(wallet: Wallet, to: address, amount: u64, transfer_id: field, signer: address) {
        //check if transfer_id exists
        assert_eq(Mapping::contains(transfers, transfer_id), false);

        //check if the offchain wallet is the same as the onchain wallet
        let onchain_wallet: Wallet = Mapping::get(wallets, wallet.wallet_address);
        assert_eq(wallet, onchain_wallet);

        //check if signer is one of the owners
        assert_eq(is_contains(wallet.owners, signer), true);

        //check if the wallet has enough balance
        let current_balance: u64 = Mapping::get(balances, wallet.wallet_address);
        assert_eq(current_balance >= amount, true);

        Mapping::set(transfers, transfer_id, Transfer {
            wallet_address: wallet.wallet_address,
            to: to,
            amount: amount,
            confirmations: 0u8,
        });
    }

    async transition confirm_transfer(signer: Signer) -> Future {
        assert_eq(signer.owner, self.signer);
        return finalize_confirm_transfer(signer.transfer_id, signer.owner);
    }

    async function finalize_confirm_transfer(transfer_id: field, signer: address) {
        assert_eq(Mapping::contains(transfers, transfer_id), true);
        let transfer: Transfer = Mapping::get(transfers, transfer_id);
        Mapping::set(transfers, transfer_id, Transfer {
            wallet_address: transfer.wallet_address,
            to: transfer.to,
            amount: transfer.amount,
            confirmations: transfer.confirmations + 1u8,
        });
    }

    async transition execute_transfer(transfer: Transfer, transfer_id: field) -> Future {
        return finalize_execute_transfer(transfer, transfer_id, credits.aleo/transfer_public(transfer.to, transfer.amount), self.signer);
    }

    async function finalize_execute_transfer(transfer: Transfer, transfer_id: field, transfer_function: Future, signer: address) {
        //check if transfer_id exists
        assert_eq(Mapping::contains(transfers, transfer_id), true);
        let onchain_transfer: Transfer = Mapping::get(transfers, transfer_id);

        //compare the offchain transfer with the onchain transfer without the confirmations
        assert_eq(transfer.wallet_address, onchain_transfer.wallet_address);
        assert_eq(transfer.to, onchain_transfer.to);
        assert_eq(transfer.amount, onchain_transfer.amount);

        //check if the signer is one of the owners
        let wallet: Wallet = Mapping::get(wallets, onchain_transfer.wallet_address);
        assert_eq(is_contains(wallet.owners, signer), true);

        //check if the confirmations are equal or greater than the threshold
        assert_eq(onchain_transfer.confirmations >= wallet.threshold, true);

        //check if the wallet has enough balance
        let current_balance: u64 = Mapping::get(balances, onchain_transfer.wallet_address);
        assert_eq(current_balance >= onchain_transfer.amount, true);

        let new_balance: u64 = current_balance - onchain_transfer.amount;
        Mapping::set(balances, onchain_transfer.wallet_address, new_balance);
        Mapping::remove(transfers, transfer_id);
        transfer_function.await();
    }

    //////////////////// Utility functions ////////////////////
    inline is_contains(array: [address; 14], element: address) -> bool {
        for i:u8 in 0u8..MAX_OWNERS {
            if array[i] == element {
                return true;
            }
        }
        return false;
    }
}
