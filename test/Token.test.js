// Import necessary dependencies
const {
  BN,
  constants,
  expectEvent,
  expectRevert,
  time,
} = require("@openzeppelin/test-helpers");
const { ZERO_ADDRESS } = constants;

// Import chai library
import("chai");

// Import contract artifacts
const Blacklist = artifacts.require("Blacklist");
const Token = artifacts.require("Token");

// Declare variables
let blacklist, token;

// Contract test suite
contract("Token", async (accounts) => {
  const [owner, account1, account2, account3] = accounts;

  // Test case: Check if the contract is deployed
  it("check if deployed", async () => {
    console.log("Owner address: ", owner);
    blacklist = await Blacklist.deployed();
    expect(blacklist.address).to.not.equal(ZERO_ADDRESS);
    console.log("BL address: ", blacklist.address);

    token = await Token.deployed();
    expect(token.address).to.not.equal(ZERO_ADDRESS);
    console.log("Token address: ", token.address);
    expect(owner).to.equal(await token.owner());
  });

  // Test case: Set blacklist
  it("set blacklist", async () => {
    await blacklist.setBlacklist([account3]);
    expect(await blacklist.isBlacklisted(account3)).to.equal(true);
  });

  // Test case: Mint tokens successfully
  it("mint ok", async () => {
    await token.mint(account1, web3.utils.toWei("100"), { from: owner });
    expect(web3.utils.fromWei(await token.balanceOf(account1))).to.equal("100");
  });

  // Test case: Mint tokens fails due to blacklisted address
  it("mint not ok", async () => {
    await expectRevert(
      token.mint(account3, web3.utils.toWei("100"), { from: owner }),
      "Address is blacklisted"
    );
  });

  // Test case: Transfer tokens successfully
  it("transfer ok", async () => {
    await token.transfer(account2, web3.utils.toWei("50"), { from: account1 });
    expect(web3.utils.fromWei(await token.balanceOf(account2))).to.equal("50");
    expect(web3.utils.fromWei(await token.balanceOf(account1))).to.equal("50");
  });

  // Test case: Transfer tokens fails due to blacklisted address
  it("transfer not ok", async () => {
    await expectRevert(
      token.transfer(account3, web3.utils.toWei("10"), { from: account1 }),
      "Address is blacklisted"
    );
  });

  // Test case: Reset address from blacklist
  it("reset from blacklist", async () => {
    await blacklist.resetBlacklist([account3]);
    expect(await blacklist.isBlacklisted(account3)).to.equal(false);
  });

  // Test case: Transfer tokens successfully to account removed from blacklist
  it("transfer ok to account removed from blacklist", async () => {
    await token.transfer(account3, web3.utils.toWei("10"), { from: account1 });
    expect(web3.utils.fromWei(await token.balanceOf(account1))).to.equal("40");
    expect(web3.utils.fromWei(await token.balanceOf(account3))).to.equal("10");
  });
});
