# AGENTS.md

## 公共基础设施约束

- 新增或修改 Docker Compose 基础设施前，必须先检查本仓库是否已经定义同类服务或 profile。
- 只被一个能力域使用的服务，放在对应 overlay。
- 被两个以上能力域使用的服务，上移到 `compose.yaml`。
- 需要强隔离、版本不同、生命周期不同的服务，允许拆成独立服务，但必须在 README/AGENTS.md 里说明原因。
- 修改基础设施后，至少运行相关 `docker compose ... config` 校验。
