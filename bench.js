const hre = require('hardhat');
const helpers = require('@nomicfoundation/hardhat-network-helpers');
const chalk = require('chalk');
const t = require('table');

/** @returns { Promise<{ structLogs: { gas: number }[] }> } */
const getTrace = hash =>
  hre.network.provider.send('debug_traceTransaction', [
    hash, {
      disableMemory: true,
      disableStack: true,
      disableStorage: true,
    },
  ]);

const bytesToKiB = n => `${(n / 2**10).toFixed(2)} KiB`;

const printTable = data => {
  const columns = data.map(d => d.length).reduce((a, b) => Math.max(a, b));
  console.log(t.table(data, {
    border: t.getBorderCharacters('norc'),
    columns: new Array(columns).fill({ alignment: 'center' }),
  }));
}

(async () => {
  const queue = [];

  for (const name of await hre.artifacts.getAllFullyQualifiedNames()) {
    const a = await hre.artifacts.readArtifact(name);
    if (a.bytecode === '0x') continue;
    const ctor = a.abi.find(x => x.type === 'constructor');
    if (ctor?.inputs.length) continue;
    const fns = a.abi.filter(x => x.type === 'function' && x.inputs.length === 0);
    const bytecodeSize = BigInt(a.bytecode.length / 2 - 1);
    const deployedSize = BigInt(a.deployedBytecode.length / 2 - 1);
    queue.push({ name, fns, bytecodeSize, deployedSize });
  }

  const sig = await hre.ethers.getSigner();

  const data = [];
  const rows = new Set();
  const addColumn = (name, col) => {
    Object.keys(col).forEach(c => rows.add(c));
    data.push({ ...col, name });
  }

  for (const { name, fns, bytecodeSize, deployedSize } of queue) {
    const d = {};
    const C = await hre.ethers.getContractFactory(name);
    const c = await C.deploy();
    d['(size)'] = bytecodeSize;
    const snap = await helpers.takeSnapshot();
    for (const fn of fns) {
      await snap.restore();
      const tx = await c.populateTransaction[fn.name]();
      const res = await sig.sendTransaction(tx);
      const rct = await res.wait();
      const trace = await getTrace(res.hash);
      const gasUsed = rct.gasUsed.toBigInt();
      const gasLimit = res.gasLimit.toBigInt();
      const gasAtStart = BigInt(trace.structLogs[0].gas);
      const transactionGas = gasLimit - gasAtStart;
      const executionGas = gasUsed - transactionGas;
      d[fn.name] = executionGas;
    }
    addColumn(name, d);
  }

  const tableData = [[''].concat(data.map(d => d.name))];
  for (const row of rows) {
    const min = data.map(d => d[row]).filter(r => r !== undefined).reduce((a, b) => a < b ? a : b);
    tableData.push([row].concat(data.map(d => {
      const val = d[row];
      if (val === undefined) {
        return '';
      } else if (val === min) {
        return chalk.green(val);
      } else {
        const dif = val - min;
        const relDif = dif * 100n / min;
        return `${val} (+${dif}) (+${relDif}%)`;
      }
    })));
  }
  printTable(tableData);
})();
