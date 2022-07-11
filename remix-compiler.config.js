module.exports = {
              compilers: {
                solc: {
                  version: '0.8.9',
                  settings: {
                    optimizer: {
                      enabled: false,
                      runs: 200,
                    },
                    evmVersion: null
                  }
                }
              }
            }