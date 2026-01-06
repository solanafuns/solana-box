# 当前环境描述

- 已安装完成 solana cli 、anchor cli 、 nodejs 、yarn 这些基础环境
- solana 账号已经初始化完成，在 devnet 有足够的 sol 完成测试
- 使用 solana 的网络 RPC 的时候可以开启本地代理转发

    ```shell
        export https_proxy=http://host.docker.internal:7890 http_proxy=http://host.docker.internal:7890 all_proxy=socks5://host.docker.internal:7890
    ```

- solana-cli version: 3.0.13
- anchor version : anchor-0.32.1
