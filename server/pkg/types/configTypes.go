package types

import (
	"fmt"
	"math/big"

	"github.com/NethermindEth/starknet.go/account"
	starkUtils "github.com/NethermindEth/starknet.go/utils"
)

type (
	Config struct {
		RegistryContractAddress string `yaml:"registry_contract_address"`
		AdminWalletSettings     string `yaml:"admin_wallet"`
	}
	AdminWallet struct {
		PrivateKey string `yaml:"private_key"`
		PublicKey  string `yaml:"public_key"`
		Address    string `yaml:"address"`
	}
)

func (w AdminWallet) GetAccount() (*account.Account, error) {
	userAddress, err := starkUtils.HexToFelt(w.Address)
	if err != nil {
		return nil, err
	}

	ks := account.NewMemKeystore()
	privKeyBI, ok := new(big.Int).SetString(w.PrivateKey, 0)
	if !ok {
		return nil, fmt.Errorf("Fail to convert privKey to bitInt")
	}
	ks.Put(w.PublicKey, privKeyBI)
	account, err := account.NewAccount(
		createRPCProvider(),
		userAddress,
		w.PublicKey,
		ks,
		account.CairoV2,
	)

	if err != nil {
		return nil, err
	}
	return account, nil
}
