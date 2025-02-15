output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = module.ecs.cluster_id
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}
