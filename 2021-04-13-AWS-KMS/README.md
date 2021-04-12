# AWS KMS and Terraform

This was a request in the YouTube comments (yes I do in fact read your comments, ALL OF THEM). The requestor wanted to know more about using AWS KMS with Terraform, and I thought that might be a fun topic. Why don't we start with some basics.

AWS KMS is a service that provides cryptographic key storage and operations. There are basically two key types it will store: symmetric and asymmetric. A symmetric key uses the same key value to both encrypt and decrypt data. Asymmetric keys have a public and private key component. Data encrypted with a public key can be decrypted with a private key, and vice versa. On KMS, asymmetric keys can be used for encryption or signing. Symmetric keys can only be used for encryption.

Those are the basics of the keys themselves. Amazon uses the KMS service for its own managed services, and those keys are called Amazon managed keys. You can also use KMS to manage keys, and those are called customer managed keys (CMKs). The key material used to generate CMK keys can come from the KMS service or be supplied by you, the customer.

That brings us to our first set of terraform resources:

* `aws_kms_key`: You use this resource to generate a key with Amazon supplied key material
* `aws_kms_external_key`: You use this resource to generate a key with customer supplied key material

Each key has a unique id, and you can also supply it with an alias. Using an alias makes it easier to remember, and helps when you want to rotate the key. Rotating the key simply means to replace the existing key with a new version. The new version will be of the same type and algorithm, but the value of the key is not related to the previous key. When rotating keys, you can assign the existing alias to the new key, and applications will start using the key.

The terraform resource to manage the alias is creatively called `aws_kms_alias`. And it does precisely what you think it does.

Accessing CMKs requires the proper permissions, and AWS has done their very best to make permissions preposterously confusing. Ugh, I'm going to try real hard here:

* **key policy** - Every key must have a key policy, and it grants permissions to the key only for the region
* **iam policy** - You can use IAM policies to grant access to one or more keys, and each key policy must allow IAM policies
* **ABAC** - You can use attributes of the key to control access to the key in a key policy or IAM policy
* **grants** - A grant allows an AWS principal to use the key, and it meant to be temporary in nature

Got that? There are **FOUR** different access control mechanisms. Here's where you define this stuff with Terraform:

* **key policy**: defined per key within the `aws_kms_key` resource.
* **iam policy**: defined using the `aws_iam_policy` resource.
* **ABAC**: you can set tags on the keys with the `aws_kms_key` resource.
* **grants**: defined using the `aws_kms_grant` resource.

There is one more KMS resource called `aws_kms_ciphertext` and it lets you encrypt plaintext into ciphertext using an existing key. Interestingly, there is also an `aws_kms_ciphertext` data source. The ciphertext you get back from the resource will be the same on every apply. The ciphertext from the data source is different on every apply. Which brings us to the data sources for KMS

The `aws_kms_key` data source will return information about a key that you can reference by key ID or alias. The `aws_kms_alias` data source let's you get the ARN or ID of the alias or its targeted key.

The last data source is `aws_kms_secrets` and this one will let you decrypt multiple secrets from data encrypted with KMS. So if you have KMS encrypted values you want to use in a Terraform config, you can decrypt and reference them with this data source. The downside is that the decrypted data will be in the Terraform logs and state. This exists b/c someone wanted it, but I can't think of a great reason why.

That's the primer on KMS and Terraform resources and data sources.

How do you use KMS with other AWS services? How long do you have?

Seriously, there are too many services to cover that use KMS in some fashion. Many use it implicitly with Amazon managed keys, while others allow you to supply a CMK instead. I'll give two simple examples here:

## EBS

You can encrypt an EBS volume with a KMS key. Here's an example configuration:

```terraform
resource "aws_kms_key" "ebs" {
  description = "EBS key"
}

resource "aws_ebs_volume" "encrypted" {
  availability_zone = data.aws_availability_zones.azs.names[0]
  size              = 40
  encrypted = true
  kms_key_id = aws_kms_key.ebs.arn
}
```

Our KMS key defaults to `ENCRYPT_DECRYPT` for `key_usage` and `SYMMETRIC_DEFAULT` for `customer_master_key_spec`. AWS will automatically create a key policy if we don't supply one. And the key defaults to being enabled. Honestly, we don't even need the description! Every field in `aws_kms_key` resource is optional.

So there is a super simple example of creating a KMS key for an EBS volume. Do you need to do anything else? Not really. We should probably give the key an alias to make it easier to refer to. That's simple enough, and we'll do that in our next example for S3.

## S3

S3 has server side encryption enabled by default using an Amazon managed key, but you can override that with your own KMS key. Let's take a look at an example where we using an existing key with an alias and assign it to our bucket.

```terraform
data "aws_kms_key" "sse_key" {
  key_id = "alias/s3SseKey"
}

resource "aws_s3_bucket" "taco_bucket" {
  bucket = "taco-bucket-04122021"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = data.aws_kms_key.sse_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
```
