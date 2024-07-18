# ------------------------------------------------------------------------------
# ECR (for each service)
# ------------------------------------------------------------------------------
module "ecr" {
  source  = "registry.terraform.io/SevenPicoForks/ecr/aws"
  version = "2.0.0"
  context = module.context.self

  enable_lifecycle_policy    = true
  encryption_configuration   = null
  image_names                = ["nodejs"]
  image_tag_mutability       = "MUTABLE"
  max_image_count            = 1000
  principals_full_access     = []
  principals_readonly_access = []
  principals_lambda          = []
  protected_tags             = []
  scan_images_on_push        = true
  use_fullname               = false
}