# AGENTS.md

## 公共基础设施约束

- 新增或修改 Docker Compose 基础设施前，必须先检查本仓库是否已经定义同类服务或 profile。
- 只被一个能力域使用的服务，放在对应 overlay。
- 被两个以上能力域使用的服务，上移到 `compose.yaml` 或共享 overlay。
- 下游仓库已经存在的公共服务，应当修正并迁移到本仓库统一的共享技术栈中，而不是继续在下游仓库重复定义。
- 需要强隔离、版本不同或生命周期不同的服务，允许拆成独立服务，但必须在 README 或 AGENTS.md 中说明原因。
- 修改基础设施后，至少运行相关 `docker compose ... config` 校验；涉及主 compose 文件时也要运行覆盖到对应 overlay/profile 的 config 校验。
