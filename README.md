# Interactive Katacoda Scenarios

## Structure

```text
repo.git
├── README.md
├── assets
│   ├── avatar.png
│   └── ...
├── <dir1>
|   |-- <scenario-dir>
│   |   ├── index.json
│   |   └── ...
|-- <dir1>-pathway.json
|-- katacoda.yaml
```

### Example

#### pathway file

`k8s-pathway.json`

```json
{
  "title": "Kubernetes",
  "description": "Kubernetes 101",
  "icon": "fa-kubernetes",
  "courses": [
    {
      "course_id": "k8s-hello",
      "title": "Olá K8s v1.08",
      "description": "Seu primeiro deploy no K8s"
    },
    {
      "course_id": "k8s-quiz",
      "title": "Interactive Quiz",
      "description": "Verify understanding and key points by using an interactive quiz"
    }
  ]
}
```

#### Directory structure

```text
k8s-pathway.json
k8s/
    k8s-hello/
        index.json
    k8s-quiz
        index.json
```

#### index.json

`k8s-hello/index.json`

```json
{
    "id": "k8s-hello",
    "pathwayId": "k8s",
    "pathwayTitle": "Kubernetes",
    "title": "Olá K8s v1.08",
    "description": "Seu primeiro deploy no K8s",
  ...
}
```

`k8s-quiz/index.json`

```json
{
    "id": "k8s-quiz",
    "pathwayId": "k8s",
    "pathwayTitle": "Kubernetes",
    "title": "Interactive Quiz",
    "description": "Verify understanding and key points by using an interactive quiz",
  ...
}
```
