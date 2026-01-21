- Follow the following conventions when generating a new API.

- For any API that has underlying AI operations i.e. LLM API calls, etc, prefix them with `generate`
  e.g. for a version API we can do `api/v1/generate/transcript`

- Use RESTful best practices, i.e. POST for create operations, GET for get operations, etc.
