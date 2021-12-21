What if you could configure workspaces on TFC and manage team access with a special workspace?

Let's do the following:

* Create workspaces from a list of workspaces
* Add tags to each workspace based on a list of tags
* Create teams based on a list of teams
* Assign roles to teams based on tags

We will need to use the TFC provider to do it.

Each workspace will be a map like this:

```terraform
workspaces = {
    workspace_name = [list, of, tags, for, workspace]
}
```

Teams will be a map like this:

```terraform
teams = {
    team_name = [members, of, team]
}
```

I guess we'll need to create users? Not sure how that will work.

And permissions will be a more complex object:

```terraform
permissions = {
    tag_name = {
        team_name = permission_level
    }
}
```