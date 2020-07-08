data "aws_iam_policy_document" "vault_kms" {
  statement {
    sid = "VaultKms"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.vault_key.arn
    ]
  }

}

resource "aws_iam_role" "vault_instance_role" {
  name = "vault-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_instance_profile" "vault_instance_profile" {
  name = "vault-profile"

  role = aws_iam_role.vault_instance_role.name
}

resource "aws_iam_role_policy_attachment" "vault-ssm" {
  role       = aws_iam_role.vault_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "vault-consul-autojoin" {
  role       = aws_iam_role.vault_instance_role.name
  policy_arn = aws_iam_policy.consul_autojoin.arn
}

resource "aws_iam_policy" "vault_seal" {
  name   = "vault_seal"
  path   = "/"
  policy = data.aws_iam_policy_document.vault_kms.json
}

resource "aws_iam_role_policy_attachment" "vault-kms" {
  role       = aws_iam_role.vault_instance_role.name
  policy_arn = aws_iam_policy.vault_seal.arn
}