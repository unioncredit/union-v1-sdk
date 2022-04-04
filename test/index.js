const { ethers } = require("hardhat");
const { parseEther } = ethers.utils;
require("chai").should();

describe("Use Voucher and Borrower", async () => {
  let voucherContract, borrowerContract, userManager, dai, unionToken, uToken;
  before(async () => {
    await network.provider.request({
      method: "hardhat_reset",
      params: [
        {
          forking: {
            jsonRpcUrl:
              "https://eth-mainnet.alchemyapi.io/v2/" +
              process.env.ALCHEMY_API_KEY,
            blockNumber: 14314100, // UNION mainnet deployment
          },
        },
      ],
    });
    [OWNER, STAKER_A, STAKER_B, STAKER_C, USER] = await ethers.getSigners();
    const admin = "0xd83b4686e434b402c2ce92f4794536962b2be3e8"; //address has usermanager auth
    const daiWallet = "0x6262998Ced04146fA42253a5C0AF90CA02dfd2A3"; //account has dai
    const unionWallet = "0xfc32e7c7c55391ebb4f91187c91418bf96860ca9"; //account has unionToken
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [admin],
    });
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [daiWallet],
    });
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [unionWallet],
    });

    const signer = await ethers.provider.getSigner(admin);
    const daiSigner = await ethers.provider.getSigner(daiWallet);
    const unionSigner = await ethers.provider.getSigner(unionWallet);
    await OWNER.sendTransaction({
      to: admin,
      value: parseEther("10"),
    });
    await OWNER.sendTransaction({
      to: unionWallet,
      value: parseEther("10"),
    });

    userManager = await ethers.getContractAt(
      "IUserManager",
      "0x49c910Ba694789B58F53BFF80633f90B8631c195"
    );
    dai = await ethers.getContractAt(
      "IERC20",
      "0x6B175474E89094C44Da98b954EedeAC495271d0F"
    );
    unionToken = await ethers.getContractAt(
      "IUnionToken",
      "0x5Dfe42eEA70a3e6f93EE54eD9C321aF07A85535C"
    );
    uToken = await ethers.getContractAt(
      "IUToken",
      "0x954F20DF58347b71bbC10c94827bE9EbC8706887"
    );

    const ExampleVoucher = await ethers.getContractFactory("ExampleVoucher");
    const ExampleBorrower = await ethers.getContractFactory("ExampleBorrower");
    voucherContract = await ExampleVoucher.deploy(
      "0x1ddB9a1F6Bc0dE1d05eBB0FDA61A7398641ae6BE",
      "0x5Dfe42eEA70a3e6f93EE54eD9C321aF07A85535C",
      "0x6b175474e89094c44da98b954eedeac495271d0f"
    );
    borrowerContract = await ExampleBorrower.deploy(
      "0x1ddB9a1F6Bc0dE1d05eBB0FDA61A7398641ae6BE",
      "0x5Dfe42eEA70a3e6f93EE54eD9C321aF07A85535C",
      "0x6b175474e89094c44da98b954eedeac495271d0f"
    );

    const amount = parseEther("1000");
    await userManager.connect(signer).addMember(STAKER_A.address);
    await userManager.connect(signer).addMember(STAKER_B.address);
    await userManager.connect(signer).addMember(STAKER_C.address);
    await dai.connect(daiSigner).transfer(STAKER_A.address, amount);
    await dai.connect(daiSigner).transfer(STAKER_B.address, amount);
    await dai.connect(daiSigner).transfer(STAKER_C.address, amount);
    await dai.connect(daiSigner).transfer(OWNER.address, amount);
    await dai.connect(STAKER_A).approve(userManager.address, amount);
    await dai.connect(STAKER_B).approve(userManager.address, amount);
    await dai.connect(STAKER_C).approve(userManager.address, amount);
    await userManager.connect(STAKER_A).stake(amount);
    await userManager.connect(STAKER_B).stake(amount);
    await userManager.connect(STAKER_C).stake(amount);

    await userManager
      .connect(STAKER_A)
      .updateTrust(voucherContract.address, amount);
    await userManager
      .connect(STAKER_B)
      .updateTrust(voucherContract.address, amount);
    await userManager
      .connect(STAKER_C)
      .updateTrust(voucherContract.address, amount);
    await userManager
      .connect(STAKER_A)
      .updateTrust(borrowerContract.address, amount);
    await userManager
      .connect(STAKER_B)
      .updateTrust(borrowerContract.address, amount);
    await userManager
      .connect(STAKER_C)
      .updateTrust(borrowerContract.address, amount);
    await unionToken.connect(signer).disableWhitelist();
    const fee = await userManager.newMemberFee();
    await unionToken.connect(unionSigner).transfer(OWNER.address, fee.mul(2));
    await unionToken.connect(OWNER).approve(voucherContract.address, fee);
    await unionToken.connect(OWNER).approve(borrowerContract.address, fee);
  });

  it("register member", async () => {
    let isMember = await voucherContract.isMember();
    isMember.should.eq(false);
    await voucherContract.registerMember();
    isMember = await voucherContract.isMember();
    isMember.should.eq(true);

    isMember = await borrowerContract.isMember();
    isMember.should.eq(false);
    await borrowerContract.registerMember();
    isMember = await borrowerContract.isMember();
    isMember.should.eq(true);
  });

  it("stake and unstake", async () => {
    const amount = parseEther("100");
    let stakeBalance = await voucherContract.getStakerBalance();
    stakeBalance.toString().should.eq("0");
    await dai.approve(voucherContract.address, amount);
    await voucherContract.stake(amount);
    stakeBalance = await voucherContract.getStakerBalance();
    stakeBalance.toString().should.eq(amount.toString());
    await voucherContract.unstake(amount);
    stakeBalance = await voucherContract.getStakerBalance();
    stakeBalance.toString().should.eq("0");

    await dai.approve(voucherContract.address, amount);
    await voucherContract.stake(amount);
  });

  it("withdraw rewards", async () => {
    const balanceBefore = await unionToken.balanceOf(OWNER.address);
    await voucherContract.withdrawRewards();
    const balanceAfter = await unionToken.balanceOf(OWNER.address);
    balanceAfter.toNumber().should.above(balanceBefore.toNumber());
  });

  it("update trust and cancel", async () => {
    const amount = parseEther("100");
    let vouchAmount = await userManager.getVouchingAmount(
      voucherContract.address,
      USER.address
    );
    vouchAmount.toString().should.eq("0");
    await voucherContract.updateTrust(USER.address, amount);
    vouchAmount = await userManager.getVouchingAmount(
      voucherContract.address,
      USER.address
    );
    vouchAmount.toString().should.eq(amount.toString());

    await voucherContract.cancelVouch(voucherContract.address, USER.address);
    vouchAmount = await userManager.getVouchingAmount(
      voucherContract.address,
      USER.address
    );
    vouchAmount.toString().should.eq("0");
  });

  it("mint and redeem", async () => {
    const amount = parseEther("100");
    let balance = await uToken.balanceOf(borrowerContract.address);
    balance.toString().should.eq("0");
    await dai.approve(borrowerContract.address, amount);
    await borrowerContract.mint(amount);
    balance = await uToken.balanceOf(borrowerContract.address);
    balance.toString().should.eq(amount.toString());
    await borrowerContract.redeem(amount);
    balance = await uToken.balanceOf(borrowerContract.address);
    balance.toString().should.eq("0");
  });

  it("borrow and repay", async () => {
    const amount = parseEther("100");
    await borrowerContract.borrow(amount);
    const fee = await uToken.calculatingFee(amount);
    let borrow = await borrowerContract.borrowBalanceView();

    parseFloat(borrow).should.eq(parseFloat(amount.add(fee)));
    await dai.approve(borrowerContract.address, ethers.constants.MaxUint256);
    // repay principal
    await borrowerContract.repayBorrow(amount);
    borrow = await borrowerContract.borrowBalanceView();
    parseFloat(borrow).should.above(parseFloat(fee));
  });
});

describe("Use Member", async () => {
  let contract, userManager, dai, unionToken, uToken;
  before(async () => {
    await network.provider.request({
      method: "hardhat_reset",
      params: [
        {
          forking: {
            jsonRpcUrl:
              "https://eth-mainnet.alchemyapi.io/v2/" +
              process.env.ALCHEMY_API_KEY,
            blockNumber: 14314100, // UNION mainnet deployment
          },
        },
      ],
    });
    [OWNER, STAKER_A, STAKER_B, STAKER_C, USER] = await ethers.getSigners();
    const admin = "0xd83b4686e434b402c2ce92f4794536962b2be3e8"; //address has usermanager auth
    const daiWallet = "0x6262998Ced04146fA42253a5C0AF90CA02dfd2A3"; //account has dai
    const unionWallet = "0xfc32e7c7c55391ebb4f91187c91418bf96860ca9"; //account has unionToken
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [admin],
    });
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [daiWallet],
    });
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [unionWallet],
    });

    const signer = await ethers.provider.getSigner(admin);
    const daiSigner = await ethers.provider.getSigner(daiWallet);
    const unionSigner = await ethers.provider.getSigner(unionWallet);
    await OWNER.sendTransaction({
      to: admin,
      value: parseEther("10"),
    });
    await OWNER.sendTransaction({
      to: unionWallet,
      value: parseEther("10"),
    });

    userManager = await ethers.getContractAt(
      "IUserManager",
      "0x49c910Ba694789B58F53BFF80633f90B8631c195"
    );
    dai = await ethers.getContractAt(
      "IERC20",
      "0x6B175474E89094C44Da98b954EedeAC495271d0F"
    );
    unionToken = await ethers.getContractAt(
      "IUnionToken",
      "0x5Dfe42eEA70a3e6f93EE54eD9C321aF07A85535C"
    );
    uToken = await ethers.getContractAt(
      "IUToken",
      "0x954F20DF58347b71bbC10c94827bE9EbC8706887"
    );

    const ExampleMember = await ethers.getContractFactory("ExampleMember");
    contract = await ExampleMember.deploy(
      "0x1ddB9a1F6Bc0dE1d05eBB0FDA61A7398641ae6BE",
      "0x5Dfe42eEA70a3e6f93EE54eD9C321aF07A85535C",
      "0x6b175474e89094c44da98b954eedeac495271d0f"
    );

    const amount = parseEther("1000");
    await userManager.connect(signer).addMember(STAKER_A.address);
    await userManager.connect(signer).addMember(STAKER_B.address);
    await userManager.connect(signer).addMember(STAKER_C.address);
    await dai.connect(daiSigner).transfer(STAKER_A.address, amount);
    await dai.connect(daiSigner).transfer(STAKER_B.address, amount);
    await dai.connect(daiSigner).transfer(STAKER_C.address, amount);
    await dai.connect(daiSigner).transfer(OWNER.address, amount);
    await dai.connect(STAKER_A).approve(userManager.address, amount);
    await dai.connect(STAKER_B).approve(userManager.address, amount);
    await dai.connect(STAKER_C).approve(userManager.address, amount);
    await userManager.connect(STAKER_A).stake(amount);
    await userManager.connect(STAKER_B).stake(amount);
    await userManager.connect(STAKER_C).stake(amount);

    await userManager.connect(STAKER_A).updateTrust(contract.address, amount);
    await userManager.connect(STAKER_B).updateTrust(contract.address, amount);
    await userManager.connect(STAKER_C).updateTrust(contract.address, amount);
    await unionToken.connect(signer).disableWhitelist();
    const fee = await userManager.newMemberFee();
    await unionToken.connect(unionSigner).transfer(OWNER.address, fee);
    await unionToken.connect(OWNER).approve(contract.address, fee);
  });

  it("register member", async () => {
    let isMember = await contract.isMember();
    isMember.should.eq(false);
    await contract.registerMember();
    isMember = await contract.isMember();
    isMember.should.eq(true);
  });

  it("stake and unstake", async () => {
    const amount = parseEther("100");
    let stakeBalance = await contract.getStakerBalance();
    stakeBalance.toString().should.eq("0");
    await dai.approve(contract.address, amount);
    await contract.stake(amount);
    stakeBalance = await contract.getStakerBalance();
    stakeBalance.toString().should.eq(amount.toString());
    await contract.unstake(amount);
    stakeBalance = await contract.getStakerBalance();
    stakeBalance.toString().should.eq("0");

    await dai.approve(contract.address, amount);
    await contract.stake(amount);
  });

  it("withdraw rewards", async () => {
    const balanceBefore = await unionToken.balanceOf(OWNER.address);
    await contract.withdrawRewards();
    const balanceAfter = await unionToken.balanceOf(OWNER.address);
    balanceAfter.toNumber().should.above(balanceBefore.toNumber());
  });

  it("update trust and cancel", async () => {
    const amount = parseEther("100");
    let vouchAmount = await userManager.getVouchingAmount(
      contract.address,
      USER.address
    );
    vouchAmount.toString().should.eq("0");
    await contract.updateTrust(USER.address, amount);
    vouchAmount = await userManager.getVouchingAmount(
      contract.address,
      USER.address
    );
    vouchAmount.toString().should.eq(amount.toString());

    await contract.cancelVouch(contract.address, USER.address);
    vouchAmount = await userManager.getVouchingAmount(
      contract.address,
      USER.address
    );
    vouchAmount.toString().should.eq("0");
  });

  it("mint and redeem", async () => {
    const amount = parseEther("100");
    let balance = await uToken.balanceOf(contract.address);
    balance.toString().should.eq("0");
    await dai.approve(contract.address, amount);
    await contract.mint(amount);
    balance = await uToken.balanceOf(contract.address);
    balance.toString().should.eq(amount.toString());
    await contract.redeem(amount);
    balance = await uToken.balanceOf(contract.address);
    balance.toString().should.eq("0");
  });

  it("borrow and repay", async () => {
    const amount = parseEther("100");
    await contract.borrow(amount);
    const fee = await uToken.calculatingFee(amount);
    let borrow = await contract.borrowBalanceView();

    parseFloat(borrow).should.eq(parseFloat(amount.add(fee)));
    await dai.approve(contract.address, ethers.constants.MaxUint256);
    // repay principal
    await contract.repayBorrow(amount);
    borrow = await contract.borrowBalanceView();
    parseFloat(borrow).should.above(parseFloat(fee));
  });
});
