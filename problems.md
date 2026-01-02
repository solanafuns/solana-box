# Known Problems and Solutions

## Solana Test Validator - AVX Support Error

### Problem

When starting `solana-test-validator`, you may encounter the following error:

```
validator-1767364235788.log
[2026-01-02T14:30:35.793374639Z INFO  solana_test_validator] agave-validator 3.0.13 (src:90098d26; feat:3604001754, client:Agave)
[2026-01-02T14:30:35.796850847Z INFO  solana_test_validator] Starting validator with: ArgsOs {
        inner: [
            "solana-test-validator",
            "-r",
        ],
    }
[2026-01-02T14:30:35.797533014Z WARN  solana_perf] CUDA is disabled
[2026-01-02T14:30:35.797649222Z ERROR solana_perf] Incompatible CPU detected: missing AVX support. Please build from source on the target
```

### Cause

The error indicates that the CPU architecture doesn't support AVX (Advanced Vector Extensions), which is required by the pre-built Solana validator binaries. This commonly occurs when:

- Running on older CPU architectures
- Using certain virtualized environments
- Running on ARM-based systems (though the container is built for `linux/amd64`)

### Solution

If you encounter this error, you may need to:

1. **Build Solana from source** on the target system to create binaries compatible with your CPU architecture
2. **Use a different CPU architecture** that supports AVX instructions
3. **Check if your environment supports AVX** - some containerized environments may not expose AVX support even if the host CPU supports it

### Workaround

The validator may still function despite this error, but performance may be degraded. Monitor the validator logs to confirm if it's actually running or if it fails to start.

