const core = require('@actions/core');
const exec = require('@actions/exec');
const io = require('@actions/io');
const fs = require('fs');
const path = require('path');

async function run() {
  try {
    // Get inputs
    const solanaKeypair = core.getInput('solana_keypair', { required: true });
    const programKeypair = core.getInput('program_keypair');
    const cluster = core.getInput('cluster') || 'devnet';
    const programPath = core.getInput('program_path') || '.';
    const programName = core.getInput('program_name');
    const solanaVersion = core.getInput('solana_version') || 'stable';
    const airdropAmount = core.getInput('airdrop_amount') || '2';

    core.info(`🚀 Starting Solana program deployment to ${cluster}`);

    // Install Solana CLI
    core.info('📦 Installing Solana CLI...');
    const solanaInstallScript = `sh -c "$(curl -sSfL https://release.solana.com/${solanaVersion}/install)"`;
    await exec.exec('bash', ['-c', solanaInstallScript]);
    
    // Add Solana to PATH
    const solanaPath = `${process.env.HOME}/.local/share/solana/install/active_release/bin`;
    core.addPath(solanaPath);

    // Verify installation
    await exec.exec('solana', ['--version']);

    // Configure Solana CLI
    core.info(`⚙️  Configuring Solana CLI for ${cluster}...`);
    await exec.exec('solana', ['config', 'set', '--url', cluster]);

    // Setup deployer keypair
    core.info('🔑 Setting up deployer keypair...');
    const deployKeypairPath = path.join(process.env.RUNNER_TEMP, 'deploy-keypair.json');
    fs.writeFileSync(deployKeypairPath, solanaKeypair);
    fs.chmodSync(deployKeypairPath, '600');
    
    await exec.exec('solana', ['config', 'set', '--keypair', deployKeypairPath]);

    // Get wallet address
    let walletAddress = '';
    await exec.exec('solana', ['address'], {
      listeners: {
        stdout: (data) => {
          walletAddress += data.toString();
        }
      }
    });
    walletAddress = walletAddress.trim();
    core.info(`💰 Wallet address: ${walletAddress}`);

    // Check balance
    let balance = '';
    await exec.exec('solana', ['balance'], {
      listeners: {
        stdout: (data) => {
          balance += data.toString();
        }
      },
      ignoreReturnCode: true
    });
    core.info(`💵 Balance: ${balance.trim() || 'Unable to fetch balance'}`);

    // Airdrop for devnet/testnet
    if (cluster !== 'mainnet-beta') {
      core.info(`💸 Requesting airdrop of ${airdropAmount} SOL...`);
      await exec.exec('solana', ['airdrop', airdropAmount], {
        ignoreReturnCode: true
      });
    }

    // Determine program name from Cargo.toml if not provided
    let actualProgramName = programName;
    if (!actualProgramName) {
      const cargoTomlPath = path.join(programPath, 'Cargo.toml');
      if (fs.existsSync(cargoTomlPath)) {
        const cargoToml = fs.readFileSync(cargoTomlPath, 'utf8');
        const nameMatch = cargoToml.match(/^name\s*=\s*"([^"]+)"/m);
        if (nameMatch) {
          actualProgramName = nameMatch[1];
        }
      }
    }

    if (!actualProgramName) {
      throw new Error('Program name not found. Please provide program_name input or ensure Cargo.toml exists.');
    }

    core.info(`📝 Program name: ${actualProgramName}`);

    // Setup program keypair
    const deployDir = path.join(programPath, 'target', 'deploy');
    await io.mkdirP(deployDir);
    
    const programKeypairPath = path.join(deployDir, `${actualProgramName}-keypair.json`);
    
    if (programKeypair) {
      core.info('🔑 Using provided program keypair...');
      fs.writeFileSync(programKeypairPath, programKeypair);
      fs.chmodSync(programKeypairPath, '600');
    } else {
      core.info('🔑 Generating new program keypair...');
      await exec.exec('solana-keygen', [
        'new',
        '--outfile', programKeypairPath,
        '--no-bip39-passphrase',
        '--force'
      ]);
    }

    // Get program ID
    let programId = '';
    await exec.exec('solana', ['address', '-k', programKeypairPath], {
      listeners: {
        stdout: (data) => {
          programId += data.toString();
        }
      }
    });
    programId = programId.trim();
    core.info(`🆔 Program ID: ${programId}`);

    // Build program
    core.info('🔨 Building Solana program...');
    await exec.exec('cargo', ['build-sbf'], {
      cwd: programPath
    });

    // Deploy program
    const programSoPath = path.join(deployDir, `${actualProgramName}.so`);
    if (!fs.existsSync(programSoPath)) {
      throw new Error(`Built program not found at ${programSoPath}`);
    }

    core.info('🚀 Deploying program...');
    await exec.exec('solana', ['program', 'deploy', programSoPath], {
      cwd: programPath
    });

    // Set outputs
    core.setOutput('program_id', programId);
    core.setOutput('program_address', programId);

    core.info(`✅ Successfully deployed program ${actualProgramName} to ${cluster}!`);
    core.info(`   Program ID: ${programId}`);

    // Cleanup
    if (fs.existsSync(deployKeypairPath)) {
      fs.unlinkSync(deployKeypairPath);
    }

  } catch (error) {
    core.setFailed(error.message);
  }
}

run();

