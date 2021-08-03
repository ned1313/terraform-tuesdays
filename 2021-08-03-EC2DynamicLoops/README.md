# Dynamic Blocks with EC2 Launch Templates

This one was a viewer request about how you can use dynamic blocks with an EC2 launch template and auto-scale groups. The source for the configuration will start as a CSV file, which we'll turn into a JSON file and import into our Terraform config. That was also a viewer request! Within the JSON file will be the launch instance information, which includes the disk layout for the launch. Each EC2 instance will have 3 disks, each with a different size and at least two performance levels.

## The CSV File

Sometimes you get to control the format of your source files. And sometimes you don't. Excel still runs the world and often you'll get a CSV file with a bunch of garbage in it and you have to turn that into infrastructure. That's fine! We can make it more consumable by converting it to JSON, a format Terraform can parse natively as a complex object.

The CSV file is included in the repository. The format is simple.

