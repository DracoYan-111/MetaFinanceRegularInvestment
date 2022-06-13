//根据公钥生成地址实例详细流程
const eccrypto = require("eccrypto");
const sha3 = require("js-sha3");
const { ethers, utils } = require("ethers");

const private_key = "4c8e0fb971250678c8aabf8556786d11988d50f96368e6e895ac34b029e4dd60";
const my_wallet = new ethers.Wallet(private_key);
const HexCharacters = "0123456789abcdef";
const public_key = my_wallet.publicKey;
printPublicKey(public_key);

//第一步: 移除公钥前两位04，如果包含0x就是移除四位了，再重新加上0x构造
let new_key = "0x" + public_key.substring(4);
//第二步：对上面的结果转化成bytesLike(不能漏)
let new_bytes = utils.arrayify(new_key);
//第三步，keccak_256,得到一个长度为64的哈希值
new_key = sha3.keccak_256(new_bytes);
//第四步，取上面结果的最后40位，就得到了全小写的地址。
let result = "0x" + new_key.substring(24);
//最后，将地址转换成检验后的地址
result = utils.getAddress(result);
console.log("____________!4");
console.log(result + "!5");
console.log(result === my_wallet.address + "!6");

function printPublicKey(public_key) {
  console.log(public_key.substring(2, 4) + "!1");
  let half = (public_key.length - 4) / 2;
  console.log(public_key.substring(4, 4 + half) + "!2");
  console.log(public_key.substring(4 + half) + "!3");
}

//unused
function convertBytesToHexString(value) {
  let result = "0x";
  for (let i = 0; i < value.length; i++) {
    let v = value[i];
    result += HexCharacters[(v & 0xf0) >> 4] + HexCharacters[v & 0x0f];
  }
  return result;
}