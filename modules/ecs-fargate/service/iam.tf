# ------------------------------------------------------------------------------
# ECS Task Execution Role Context
# ------------------------------------------------------------------------------
module "task_exec_policy_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["task", "exec", "policy"]
}

module "task_policy_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  enabled    = module.context.enabled && length(var.task_role_policy_docs) > 0
  attributes = ["task", "policy"]
}


# ------------------------------------------------------------------------------
# ECS Task Execution Role
# ------------------------------------------------------------------------------
resource "aws_iam_policy" "task_exec_policy" {
  count       = module.task_exec_policy_context.enabled ? 1 : 0
  policy      = join("", data.aws_iam_policy_document.task_exec_policy_doc.*.json)
  name        = module.task_exec_policy_context.id
  description = "Task Exec Policy for ${module.context.id}"
  tags        = module.task_exec_policy_context.tags
}

data "aws_iam_policy_document" "task_exec_policy_doc" {
  count                   = module.task_exec_policy_context.enabled ? 1 : 0
  source_policy_documents = values(var.task_exec_role_policy_docs)
}

# ------------------------------------------------------------------------------
# ECS Task Role
# ------------------------------------------------------------------------------
resource "aws_iam_policy" "task_policy" {
  count       = module.task_policy_context.enabled ? 1 : 0
  policy      = try(data.aws_iam_policy_document.task_policy_doc[0].json, "")
  name        = module.task_policy_context.id
  description = "Task Policy for ${module.context.id}"
  tags        = module.task_policy_context.tags
}

data "aws_iam_policy_document" "task_policy_doc" {
  count                   = module.task_policy_context.enabled ? 1 : 0
  source_policy_documents = values(var.task_role_policy_docs)
}