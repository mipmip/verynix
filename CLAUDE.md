When I refer to issues like technative-project-proposals-63wm checkout the task
in @.beans/technative-project-proposals-63wm-*.md

In this project we will use these tasks as epics for making openspec proposals. 

WHEN you create a proposal at a link to this task in the proposal.md.
WHEN a bean is used to create an proposal change the status to "in-progress"
WHEN a proposal is archived add the link to the archived proposal in the frontmatter of this task like this:

```
openspec-link: openspec/changes/archive/....
```

You are allowed to update these statuses in the task frontmatter:

- in-progress                                             
- todo
- draft
- completed
- scrapped

When making changes you are allowed to update the date/time in `updated_at` in the task frontmatter 

Besides updating status and openspec-link, you are NOT ALLOWED to modify the contents of the task file.
