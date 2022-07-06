const { task } = require('hardhat/config');
const { HardhatError } = require('hardhat/internal/core/errors');
const { ERRORS } = require('hardhat/internal/core/errors-list');
const { TASK_COMPILE_SOLIDITY_CHECK_ERRORS, TASK_COMPILE_SOLIDITY_LOG_COMPILATION_ERRORS } = require('hardhat/builtin-tasks/task-names');

require('@nomiclabs/hardhat-ethers');

const WARN_MUTABILITY = '2018';
const IGNORED_WARNINGS = [WARN_MUTABILITY];

task(TASK_COMPILE_SOLIDITY_CHECK_ERRORS, async ({ output, quiet }, { run }) => {
  const errors = output.errors && output.errors.filter(e => !IGNORED_WARNINGS.includes(e.errorCode)) || [];

  await run(TASK_COMPILE_SOLIDITY_LOG_COMPILATION_ERRORS, {
    output: { ...output, errors },
    quiet,
  });

  if (errors.length > 0) {
    throw new HardhatError(ERRORS.BUILTIN_TASKS.COMPILE_FAILURE);
  }
});



/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      '0.8.14',
    ].map(v => ({
      version: v,
      settings: {
        optimizer: {
          enabled: true,
        },
      },
    })),
  },
};
