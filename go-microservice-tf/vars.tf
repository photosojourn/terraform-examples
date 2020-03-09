variable "deploy_image" {
  description = "The URI of the image used for the Helm deploy."
  type        = "string"
}

variable "github_token" {
  description = "The Github token to allow CodePipeline to access the code."
  type        = "string"
}